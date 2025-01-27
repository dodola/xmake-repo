package("libx11")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Core X11 protocol client library")

    set_urls("https://www.x.org/archive/individual/lib/libX11-$(version).tar.gz")
    add_versions("1.6.9", "b8c0930a9b25de15f3d773288cacd5e2f0a4158e194935615c52aeceafd1107b")
    add_versions("1.7.0", "c48ec61785ec68fc6a9a6aca0a9578393414fe2562e3cc9cca30234345c7b6ac")
    add_versions("1.7.3", "029acf61e7e760a3150716b145a58ce5052ee953e8cccc8441d4f550c420debb")

    if is_plat("linux") then
        add_syslinks("dl")
        add_extsources("apt::libx11-dev", "pacman::libx11")
    elseif is_plat("macosx") then
        add_extsources("brew::libx11")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xtrans", "libxcb", "xorgproto")
    end
    if is_plat("macosx") then
        -- fix sed: RE error: illegal byte sequence
        add_deps("gnu-sed")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-unix-transport",
                         "--enable-tcp-transport",
                         "--enable-ipv6",
                         "--enable-local-transport",
                         "--enable-loadable-i18n",
                         "--enable-xthreads",
                         "--enable-specs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XOpenDisplay", {includes = "X11/Xlib.h"}))
    end)
