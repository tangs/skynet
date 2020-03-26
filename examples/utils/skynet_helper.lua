-- 服务通用返回格式
local function mk_res(ret_code, err_msg)
    return {
        ret_code = ret_code,
        err_msg = err_msg or "",
        msges = {
        }
    }
end

return {
    mk_res = mk_res,
}
