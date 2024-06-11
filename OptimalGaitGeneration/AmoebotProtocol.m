classdef AmoebotProtocol < handle
    % AmoebotProtocol: Communication protocol for Amoebot control.
    %   This class handles communication with the Amoebot, providing methods
    %   for connecting, disconnecting, and sending various commands.


    %% Protected member variable.
    properties (Access = protected)
        popup
    end

    %% Read-Only member variable.
    properties (SetAccess=protected, GetAccess=public)
        client
        ip
        isConnected
        isPopup
        dataContainer = {};
        dxlCurPos = [];
        dxlPosLim = [];
        TrajBeginEndTime = [0,0];
    end

    properties (Constant)

        % Packet Information.
        header = [0xff 0xfd 0xcf];
        tail = [0x0d 0x0a 0xef 0xcd];
        msgTypeOffset = 3;
        msgLengthOffset = 4;
        msgDataOffset = 5;
        msgHtSize = 7;
        msgAppendixSize = 2;
        tailSize = 4;

        % Msg Instruction.
        STRING_MSG = 0x01;
        TOQUE_ON_MSG = 0x02;
        TOQUE_OFF_MSG = 0x03;
        ACT_GOAL_TRAJ_MSG = 0x04;
        L_DXL_GOAL_POS_MSG = 0x05;
        R_DXL_GOAL_POS_MSG = 0x06;
        LIN_ACT_GOAL_POS_MSG = 0x07;
        L_DXL_CUR_POS_MSG = 0x08;
        R_DXL_CUR_POS_MSG = 0x09;
        LIN_ACT_CUR_POS_MSG = 0x0A;
        ACT_POS_LIM_MSG = 0x0B;
        % ToDo: add the instruction for time-based profile cmd.
    end

    %% Public method
    methods (Access = public)

        % Constructor
        % isPopup: Choose the way how to display the log from Amoebot.
        % If it is 1, GUI opens. If it is 0, use CommandWindow.
        function obj = AmoebotProtocol(isPopup)
            arguments
                isPopup = 0
            end
            obj.isConnected = false;
            obj.isPopup = isPopup;
            % Setting the Popup.
            if isPopup
                obj.popup = logPopup();
            end
        end

        % Connect to the Amoebot.
        function Connect(obj,ip)

            if ~exist("ip","var")
                ip = '192.168.4.1';
            end

            obj.ip = ip;

            if obj.isConnected
                obj.println("Client is already connected!");
                return;
            end
            try
                % Try to connect.
                obj.client = tcpclient(ip,80,"ConnectTimeout",10,"EnableTransferDelay",false);
                configureCallback(obj.client,"terminator",@(a,b) obj.UpdateLogCallback(a,b));
                obj.isConnected = true;

                obj.println("Succesfully Connected");
            catch ME

                % If the connection is failed, dipslay the message.
                disp(ME.message);
            end
        end

        % Disconnect to the Amoebot.
        function Disconnect(obj)

            if obj.isConnected
                obj.client = [];
                obj.isConnected = false;
            else
                obj.println("Client is already disconnected!");
            end
        end

        % Send string data to Amoebot
        function SendString(obj,sendData)
            % construct packet.
            if(isstring(sendData))
                sendData = char(sendData);
            end

            obj.Send(obj.STRING_MSG,sendData);
        end

        % Send general command to Amoebot.
        % Msg length will be automatically calculated.
        % SendInst: The pre-defined instruction. Check the constant
        % member variables.
        % SendData: The actual data section. 
        %           It should be uint8 array or char array.
        function Send(obj,SendInst,SendData)
            if ~exist('SendData','var')
                SendData = [];
            end
            if obj.isConnected
                try

                    lenData = length(SendData) + length(SendInst) + 1;

                    Packet = ([obj.header SendInst lenData SendData obj.tail]);

                    obj.client.write(Packet);
                catch ME
                    obj.isConnected = false;
                    obj.println(ME.message);
                end
            else
                obj.println("The client is currently not connected to the Amoebot.")
            end
        end

        % Set goal position for an actuator
        function SetGoalPos(obj, ActId, GoalPos)
            SendInst = uint8(ActId + obj.L_DXL_GOAL_POS_MSG - 1);
            SendData = [typecast(uint32(GoalPos),'uint8')];
            obj.Send(SendInst, SendData);
        end

        % Set goal trajectory for an actuator.
        function SetGoalTrajectory(obj, TrajData)
            % Before using this command, you should get actuation
            % limit information. TrajData should be nx4 double array, 
            % but n should be less than or equal to 10. 
            % First column: target time (ms).
            % Second column: left dynamixel trajectory (rad).
            % Third column: left dynamixel trajectory (rad).
            % Fourth column: Linear actuator trajectory (0~1000 integer).
            % (Todo: change unit to mm or in).
            
            if (size(TrajData,1) > 10)               
                obj.println("The length of trajectory should be less than 10.");
                return
            end

            if (size(TrajData,2) ~= 4)                
                obj.println("The number of trajectory should be equal" + ...
                    " to (the number of actuator + 1)");
                return
            end

            if isempty(obj.dxlPosLim)
                obj.println("Get the actuation limit information at first.");
                return
            end            

            RadToDxlUnit = 4096/(2*pi);

            TrajData(:,2) = TrajData(:,2)*RadToDxlUnit + obj.dxlPosLim(1);
            TrajData(:,3) = obj.dxlPosLim(4) - TrajData(:,3)*RadToDxlUnit;
            TrajData(:,4) = obj.dxlPosLim(5) + TrajData(:,4);

            if any([(TrajData(:,2) < obj.dxlPosLim(1)), ...
                    (TrajData(:,2) > obj.dxlPosLim(2)), ...
                    (TrajData(:,3) < obj.dxlPosLim(3)), ...
                    (TrajData(:,3) > obj.dxlPosLim(4)), ...
                    (TrajData(:,4) < obj.dxlPosLim(5)), ...
                    (TrajData(:,4) > obj.dxlPosLim(6))],'all')
                obj.println("Trajectory exceeds the actuation limit.");
                return
            end

            TrajData = reshape(TrajData,[1 numel(TrajData)]);
            TrajData = uint32(TrajData);
            SendData = typecast(TrajData,'uint8');
            obj.Send(obj.ACT_GOAL_TRAJ_MSG,SendData);
        end
    end


    %% Protected method
    methods (Access = protected)
        function UpdateLogCallback(obj,~,~)
            readData = obj.client.read();

            % Extract packets and check if each packet is string-type msg 
            % or actuator information type msg.
            obj.ExtractDatas(readData);
        end

        function print(obj,str)
            % If GUI is empty, print it in console.
            % If not, print it in GUI.
            if isempty(obj.popup)
                newstr = erase(str,char(13));
                disp(newstr);
            elseif ~isvalid(obj.popup)
                obj.popup = logPopup();
                obj.popup.print(str);
            else
                obj.popup.print(str);
            end
        end

        function println(obj,str)
            % If GUI is empty, print it in console.
            % If not, print it in GUI.
            if isempty(obj.popup)
                newstr = erase(str,char(13));
                disp(newstr);
            elseif ~isvalid(obj.popup)
                obj.popup = logPopup();
                obj.popup.println(str);
            else
                obj.popup.println(str);
            end
        end

        function ExtractDatas(obj,data)
            % Find where header and tail are.
            hIdx = strfind(data,obj.header);
            tIdx = strfind(data,obj.tail);

            % If header has the same length as tail,
            % we assume that it is undamaged packet.
            if (length(hIdx) == length(tIdx))
                for i = 1:length(hIdx)

                    % Check the message type and length.
                    msgType = data(hIdx(i) + obj.msgTypeOffset);
                    msgLength = data(hIdx(i) + obj.msgLengthOffset);

                    range = (hIdx(i)+obj.msgDataOffset):(tIdx(i)-1);
                    msgData = data(range);

                    % Extract and save the data in the object.
                    obj.ExtractOneData(msgData,msgType,msgLength);

                end
            else
                obj.println("Incomplete packet recieved.")
            end
        end

        % Extract data from one received packet
        function ExtractOneData(obj,msgData,msgType,msgLength)

            % Check the message length.
            if (msgLength == (length(msgData) + obj.msgAppendixSize ))
                switch msgType
                    case obj.STRING_MSG
                        % If it is string type, print it.
                        obj.println(char(msgData));

                    case obj.ACT_GOAL_TRAJ_MSG
                        obj.TrajBeginEndTime = typecast(msgData,'uint32');

                    case obj.L_DXL_CUR_POS_MSG
                        obj.dxlCurPos(1) = typecast(msgData,'uint32');

                    case obj.R_DXL_CUR_POS_MSG
                        obj.dxlCurPos(2) = typecast(msgData,'uint32');

                    case obj.ACT_POS_LIM_MSG
                        obj.dxlPosLim = zeros(1,6);
                        for i = 1:6
                            obj.dxlPosLim(i) = typecast(msgData(4*i-3:4*i),'uint32');
                        end
                    otherwise
                        obj.dataContainer = [obj.dataContainer; {msgData}];
                end
            else
                obj.println("Incomplete packet recieved.")
            end
        end
    end
end