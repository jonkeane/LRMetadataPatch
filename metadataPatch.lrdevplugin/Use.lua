if _G.use == nil then

    local LrPathUtils = import 'LrPathUtils'

    function use_module (module)
        local sep = WIN_ENV and '\\' or '/'
        local path = module:gsub ('%.', sep)

        local full_path = LrPathUtils.addExtension (LrPathUtils.child (_PLUGIN.path, path), 'lua')

        local fun, error = loadfile (full_path)
        if not fun then
            return require (module)
        end

        return fun ()    
    end

    _G.use = use_module
end
