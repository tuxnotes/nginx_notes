
-- This lua script is located in /opt/app/openresty/lualib/rule.lua

local _M = { _VERSION = '0.0.1' }

function _M.check(server)
    local balancer = require "ngx.balancer"

    local backend_host = ""
    local backend_port = ""
    local serialno = ""
    local client_ip = ngx.var.client_ip
    local key = os.time()
    local hash = ngx.crc32_long(client_ip)
    local allow_host = {}
    local allow_ip_host = {}
    local allow_all_host = {}

    for i = 1, #server do
        access_list = server[i].access
        for j = 1, #server[i].access do
            if (access_list[j] == client_ip) then
                table.insert(allow_ip_host, server[i])
            elseif (server[i].access[j] == "all") then
                table.insert(allow_all_host, server[i])
            end
        end
    end

    if (#allow_host > 0) then
        hash = (hash % #allow_host) + 1
        backend_host = allow_host[hash].host
        backend_port = allow_host[hash].port
        sefialno = allow_host[hash].serialno
    else
        backend_host = "10.1.201.200"
        backend_port = "81"
        sefialno = "0"
        ngx.log(ngx.DEBUG, "The IP address does not have access permission: ", client_ip)
    end

    local ok, err = balancer.set_current_peer(backend_host, backend_port)
    if not ok then
        ngx.log(ngx.ERR, "failed to set the current peer: ", err)
        return ngx.exit(500)
    end

    ngx.log(ngx.DEBUG, "log_type=route", "|domain=", ngx.var.server_name, "|context=", ngx.var.location, "|serialno=", serialno, "|client=", client_ip, "|backend=", backend_host,":",backend_port)
end

return _M

