#!/usr/bin/bash

# A command line binary cannot embed resource files.
# Thus we need to take the assets we need to bundle, and encode them into the app for use at runtime.


#Eliminate any pregenerated variables
rm -f ./snapdiff/Generated.swift

#Read and minify the stylesheet into a variable
cat ./snapdiff/style.css | sed -e 's/^[ \t]*//g; s/[ \t]*$//g; s/\([:{;,]\) /\1/g; s/ {/{/g; s/\/\*.*\*\///g; /^$/d' | sed -e :a -e '$!N; s/\n\(.\)/\1/; ta' | awk '{print "let __generated_var_css = \"" $0"\"\n"}' >>  ./snapdiff/Generated.swift

#Read and minify the main html template into a variable
cat ./snapdiff/main_html_template.html | tr -d '\n'| sed 's/"/\\"/g' | awk '{print "let __generated_var_html_template = \"" $0"\"\n"}' >>  ./snapdiff/Generated.swift

#Read and minify the test div html template into a variable
cat ./snapdiff/test_div_template.html | tr -d '\n' | sed 's/"/\\"/g' | awk '{print "let __generated_var_div_template = \"" $0"\"\n"}' >>  ./snapdiff/Generated.swift
