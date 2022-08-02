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

            void test(int argc, char *argv[])
            {
                enum {eoi, word, ws, newline};
                lexertl::rules rules_;
                lexertl::state_machine sm_;

                rules_.insert_macro("ws", "[ \t]");
                rules_.insert_macro("nonws", "[^ \t\n]");
                rules_.push("{nonws}+", word);
                rules_.push("{ws}+", ws);
                rules_.push("\r|\n|\r\n", newline);
                lexertl::generator::build(rules_, sm_);
            //    lexertl::debug::dump(sm_, std::cout);

                lexertl::memory_file if_(argc == 2 ? argv[1] :
                    "include/lexertl/licence_1_0.txt");
                const char *start_ = if_.data();
                const char *end_ = start_ + if_.size();
                lexertl::cmatch results_(start_, end_);
                int cc = 0, wc = 0, lc = 0;

                do
                {
                    lexertl::lookup(sm_, results_);

                    switch (results_.id)
                    {
                    case eoi:
                        break;
                    case word:
                        cc += results_.second - results_.first;
                        ++wc;
                        break;
                    case ws:
                        cc += results_.second - results_.first;
                        break;
                    case newline:
                        ++lc;
                        cc += results_.second - results_.first;
                        break;
                    default:
                        assert(0);
                        break;
                    }
                } while (results_.id != eoi);

                std::cout << "lines: " << lc << ", words: " << wc <<
                    ", chars: " << cc << '\n';
                return 0;
            }

        ]]}, {configs = {languages = "c++14"},
            includes = {}}))
    end)

