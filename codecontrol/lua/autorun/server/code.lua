util.AddNetworkString("ChangeCodeStatus")
util.AddNetworkString("ClientCodeUpdate")
net.Receive("ChangeCodeStatus",function()
    code = net.ReadString()
    --print("Server recieved!", code)
    net.Start("ClientCodeUpdate")
        net.WriteString( code )
    net.Broadcast()
    end )