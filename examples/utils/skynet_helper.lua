-- 服务通用返回格式
local function mk_res(ret_code, res_msg)
    return {
        ret_code = ret_code,
        res_msg = res_msg,
        msges = {
        }
    }
end

return {
    mk_res = mk_res,
}
