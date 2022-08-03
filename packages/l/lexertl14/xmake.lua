package("lexertl14")

    set_homepage("http://www.benhanson.net/lexertl/download.html")
    set_description("lexertl is a header-only library for writing lexical analysers.")

    add_urls("https://github.com/BenHanson/lexertl14.git")
    add_versions("2020-12-14", "4a4b4e67480fc436c074c832b9eaa379941a9e8c")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_includedirs("include", "include")

    add_linkdirs("lib/lexertl")

    add_links("lexertl14")

    add_deps("cmake")

    on_install("linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_TYPE=" .. (package:config("shared") and "Shared" or "Static"))
        import("package.tools.cmake").install(package, configs, {})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            
            #include <lexertl/generator.hpp>
            #include <lexertl/lookup.hpp>
            #include <lexertl/memory_file.hpp>

            void test()
            {
                typedef lexertl::detail::basic_re_tokeniser_state<char, std::size_t> state;
                typedef lexertl::detail::basic_re_tokeniser
                    <char, char, std::size_t> tokeniser;
                std::string str_("\[\[:xdigit:\]\]");
                state state_(str_.c_str(), str_.c_str() + str_.size(), 1, 0, std::locale(""), 0);
                lexertl::detail::basic_re_token<char, char> lhs_;
                lexertl::detail::basic_re_token<char, char> token_;

                tokeniser::next(lhs_, state_, token_);
            }

        ]]}, {configs = {languages = "c++14"},
            includes = {}}))
    end)

