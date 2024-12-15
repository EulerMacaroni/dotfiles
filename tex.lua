local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node

return {
	-- LaTeX Template Snippet
	s("template", {
		t({
			"\\documentclass[a4paper]{article}",
			"",
			"\\usepackage[utf8]{inputenc}",
			"\\usepackage[T1]{fontenc}",
			"\\usepackage{textcomp}",
			"\\usepackage[dutch]{babel}",
			"\\usepackage{amsmath, amssymb}",
			"",
			"% figure support",
			"\\usepackage{import}",
			"\\usepackage{xifthen}",
			"\\pdfminorversion=7",
			"\\usepackage{pdfpages}",
			"\\usepackage{transparent}",
			"\\newcommand{\\incfig}[1]{%",
			"  \\def\\svgwidth{\\columnwidth}",
			"  \\import{./figures/}{#1.pdf_tex}",
			"}",
			"",
			"\\pdfsuppresswarningpagegroup=1",
			"",
			"\\begin{document}",
			"\t",
		}),
		i(0), -- Placeholder for user input
		t({
			"",
			"\\end{document}",
		}),
	}),
	-- Begin-End Environment
	s("beg", {
		t("\\begin{"),
		i(1, "environment"), -- Placeholder for the environment name
		t({ "}", "\t" }),
		i(0), -- Placeholder for the content
		t({ "", "\\end{" }),
		i(1), -- Automatically matches the environment name
		t("}"),
	}),

	-- Ellipsis (ldots)
	s("...", {
		t("\\ldots"),
	}),

	-- Table Environment
	s("table", {
		t({ "\\begin{table}[" }),
		i(1, "htpb"),
		t({ "]", "\t\\centering", "\t\\caption{" }),
		i(2, "caption"),
		t({ "}", "\t\\label{tab:" }),
		i(3, "label"),
		t({ "}", "\t\\begin{tabular}{" }),
		i(4, "c"), -- Placeholder for tabular column alignment (e.g., c, l, r)
		t({ "}", "\t" }),
		i(0), -- Placeholder for the tabular content
		t({ "", "\t\\end{tabular}", "\\end{table}" }),
	}),

	-- Figure Environment
	s("fig", {
		t({ "\\begin{figure}[" }),
		i(1, "htpb"),
		t({ "]", "\t\\centering", "\t" }),
		i(2, "\\includegraphics[width=0.8\\textwidth]{"),
		i(3, "filename"),
		t({ "}", "\t\\caption{" }),
		i(4, "caption"),
		t({ "}", "\t\\label{fig:" }),
		i(5, "label"),
		t({ "}", "\\end{figure}" }),
	}),
	-- Enumerate Environment
	s("enum", {
		t({ "\\begin{enumerate}", "\t\\item " }),
		i(0), -- Placeholder for list items
		t({ "", "\\end{enumerate}" }),
	}),

	-- Itemize Environment
	s("item", {
		t({ "\\begin{itemize}", "\t\\item " }),
		i(0), -- Placeholder for list items
		t({ "", "\\end{itemize}" }),
	}),

	-- Description Environment
	s("desc", {
		t({ "\\begin{description}", "\t\\item[" }),
		i(1, "label"), -- Placeholder for the label
		t({ "] " }),
		i(0), -- Placeholder for the description
		t({ "", "\\end{description}" }),
	}),

	-- Usepackage Snippet
	s("pac", {
		t("\\usepackage["),
		i(1, "options"), -- Placeholder for options
		t("]{"),
		i(2, "package"), -- Placeholder for package name
		t("}"),
	}),

	-- Implies Symbol
	s("=>", {
		t("\\implies"),
	}),

	-- Implied By Symbol
	s("=<", {
		t("\\impliedby"),
	}),

	-- Iff Symbol (in Math Context)
	s("iff", {
		t("\\iff"),
	}),
	-- Math Mode Inline
	s("mk", {
		t("$"),
		i(1), -- Placeholder for the content inside the math mode
		t("$"),
		d(2, function(_, snip)
			local next_char = snip.env.POSTJUMP
			if next_char and not string.match(next_char, "[,%.%?%- ]") then
				return sn(nil, { t(" ") })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),

	-- Display Math Environment
	s("dm", {
		t({ "\\[", "\t" }),
		i(1), -- Placeholder for the content inside the display math
		t({ "", "\\]" }),
	}),

	-- Align Environment
	s("ali", {
		t({ "\\begin{align*}", "\t" }),
		i(1), -- Placeholder for the align content
		t({ "", "\\end{align*}" }),
	}),

	-- Fraction with cursor positions
	s("//", {
		t("\\frac{"),
		i(1), -- Numerator
		t("}{"),
		i(2), -- Denominator
		t("}"),
	}),

	-- Fraction with visual selection
	s("/", {
		t("\\frac{"),
		i(1, "VISUAL"), -- Placeholder for the visual selection
		t("}{"),
		i(2), -- Placeholder for the denominator
		t("}"),
	}),
	-- Symbol Fraction Snippet
	s({ trig = "([%d]*[A-Za-z]+)(%d*)" }, {
		f(function(_, snip)
			local symbol = snip.captures[1] or ""
			return "\\frac{" .. symbol .. "}{"
		end),
		i(1), -- Placeholder for the denominator
		t("}"),
	}),

	-- () Fraction Snippet
	s({ trig = "^.*%)" }, {
		f(function(_, snip)
			local stripped = snip.trigger:sub(1, -2)
			local depth = 0
			local i1 = #stripped
			while i1 > 0 do
				if stripped:sub(i1, i1) == ")" then
					depth = depth + 1
				elseif stripped:sub(i, i) == "(" then
					depth = depth - 1
				end
				if depth == 0 then
					break
				end
				i1 = i1 - 1
			end
			local numerator = stripped:sub(i1 + 1, -1)
			local prefix = stripped:sub(1, i1 - 1)
			return prefix .. "\\frac{" .. numerator .. "}"
		end),
		t("{"),
		i(1), -- Placeholder for the denominator
		t("}"),
	}),

	-- Auto Subscript Snippet
	s({ trig = "([A-Za-z])(%d)" }, {
		f(function(_, snip)
			local base = snip.captures[1]
			local subscript = snip.captures[2]
			return base .. "_" .. subscript
		end),
	}),

	-- Auto Subscript2 Snippet
	s({ trig = "([A-Za-z])_(%d%d)" }, {
		f(function(_, snip)
			local base = snip.captures[1]
			local subscript = snip.captures[2]
			return base .. "_{" .. subscript .. "}"
		end),
	}),
	-- Symbol Fraction
	s("symbol_frac", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local match = string.match(input, "((%d+)|(%d*)(\\)?([A-Za-z]+)((%^)_(%d+)|%d))")
			if match then
				return sn(nil, { t("\\frac{" .. match .. "}{"), i(1), t("}") })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),

	-- Fraction from closing parenthesis
	s("paren_frac", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local stripped = string.sub(input, 1, -2)
			local depth = 0
			local i = #stripped
			while i > 0 do
				if string.sub(stripped, i, i) == ")" then
					depth = depth + 1
				end
				if string.sub(stripped, i, i) == "(" then
					depth = depth - 1
				end
				if depth == 0 then
					break
				end
				i = i - 1
			end
			local numerator = string.sub(stripped, i + 1, -1)
			local before = string.sub(stripped, 1, i - 1)
			return sn(nil, { t(before .. "\\frac{" .. numerator .. "}{"), i(1), t("}") })
		end, {}),
	}),

	-- Auto subscript for single-digit subscripts
	s("auto_subscript", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local match = string.match(input, "([A-Za-z])(%d)")
			if match then
				return sn(nil, { t(match .. "_"), i(1) })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),

	-- Auto subscript for double-digit subscripts
	s("auto_subscript2", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local match1, match2 = string.match(input, "([A-Za-z])_(%d%d)")
			if match1 and match2 then
				return sn(nil, { t(match1 .. "_{" .. match2 .. "}") })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),

	-- Sympy block
	s("sympy", {
		t("sympy "),
		i(1), -- Placeholder for the user to type
		t(" sympy"),
	}),

	-- Sympy Dynamic Conversion to LaTeX
	s("sympy_dynamic", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local expr = string.match(input, "sympy(.*)sympy")
			if expr then
				-- Simulating Python sympy logic in Lua
				expr = expr:gsub("\\", ""):gsub("%^", "**"):gsub("{", "("):gsub("}", ")")
				-- Here we would need to actually call Python to run `latex(expr)`
				-- but since we can't execute Python directly in LuaSnip, we'll simulate it.
				-- Replace this with a static placeholder for now
				return sn(nil, { t("\\text{Sympy LaTeX of " .. expr .. "}") })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),

	-- Mathematica block
	s("math", {
		t("math "),
		i(1), -- Placeholder for user input
		t(" math"),
	}),

	-- Mathematica Dynamic Conversion to TeXForm
	s("math_dynamic", {
		d(1, function(_, snip)
			local input = snip.env.POSTJUMP or ""
			local expr = string.match(input, "math(.*)math")
			if expr then
				-- Simulating Mathematica logic in Lua
				local code = "ToString[" .. expr .. ", TeXForm]"
				-- Normally, we would run `wolframscript -code` but since we can't run system commands
				-- here, we'll use a placeholder for now.
				return sn(nil, { t("\\text{Mathematica TeXForm of " .. code .. "}") })
			else
				return sn(nil, { t("") })
			end
		end, {}),
	}),
	-- Equals with alignment
	s("==", {
		t("&= "),
		i(1), -- Placeholder for the content
		t(" \\\\"),
	}),

	-- Not equals symbol
	s("!=", {
		t("\\neq"),
	}),

	-- Ceiling function in math environment
	s("ceil", {
		t("\\left\\lceil "),
		i(1), -- Placeholder for the content inside the ceiling
		t(" \\right\\rceil "),
		i(0), -- Final cursor position
	}),

	-- Floor function in math environment
	s("floor", {
		t("\\left\\lfloor "),
		i(1), -- Placeholder for the content inside the floor
		t(" \\right\\rfloor"),
		i(0), -- Final cursor position
	}),

	-- pmatrix environment
	s("pmat", {
		t("\\begin{pmatrix} "),
		i(1), -- Placeholder for matrix content
		t(" \\end{pmatrix} "),
		i(0), -- Final cursor position
	}),

	-- bmatrix environment
	s("bmat", {
		t("\\begin{bmatrix} "),
		i(1), -- Placeholder for matrix content
		t(" \\end{bmatrix} "),
		i(0), -- Final cursor position
	}),

	-- Left-right parentheses in math environment
	s("()", {
		t("\\left( "),
		i(1, "VISUAL"), -- Placeholder for the content inside the parentheses
		t(" \\right) "),
		i(0), -- Final cursor position
	}),

	-- Left-right parentheses (alternative trigger `lr`)
	s("lr", {
		t("\\left( "),
		i(1, "VISUAL"), -- Placeholder for the content inside the parentheses
		t(" \\right) "),
		i(0), -- Final cursor position
	}),
	-- Left( ... ) Right Parentheses
	s("lr(", {
		t("\\left( "),
		i(1, "VISUAL"), -- Placeholder for the content inside the parentheses
		t(" \\right) "),
		i(0), -- Final cursor position
	}),

	-- Left| ... | Right Absolute Value
	s("lr|", {
		t("\\left| "),
		i(1, "VISUAL"), -- Placeholder for the content inside the absolute value
		t(" \\right| "),
		i(0), -- Final cursor position
	}),

	-- Left{ ... } Right Braces
	s("lr{", {
		t("\\left\\{ "),
		i(1, "VISUAL"), -- Placeholder for the content inside the braces
		t(" \\right\\} "),
		i(0), -- Final cursor position
	}),

	-- Left{ ... } Right Braces (duplicate of lr{)
	s("lrb", {
		t("\\left\\{ "),
		i(1, "VISUAL"), -- Placeholder for the content inside the braces
		t(" \\right\\} "),
		i(0), -- Final cursor position
	}),

	-- Left[ ... ] Right Brackets
	s("lr[", {
		t("\\left[ "),
		i(1, "VISUAL"), -- Placeholder for the content inside the brackets
		t(" \\right] "),
		i(0), -- Final cursor position
	}),

	-- Left< ... > Right Angle Brackets
	s("lra", {
		t("\\left<"),
		i(1, "VISUAL"), -- Placeholder for the content inside the angle brackets
		t("\\right>"),
		i(0), -- Final cursor position
	}),

	-- Conjugate (overline)
	s("conj", {
		t("\\overline{"),
		i(1), -- Placeholder for the content to conjugate
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Summation
	s("sum", {
		t("\\sum_{n="),
		i(1, "1"), -- Placeholder for the lower limit
		t("}^{"),
		i(2, "\\infty"), -- Placeholder for the upper limit
		t("} "),
		i(3, "a_n z^n"), -- Placeholder for the sum's content
		i(0), -- Final cursor position
	}),
	-- Taylor Series
	s("taylor", {
		t("\\sum_{"),
		i(1, "k"), -- Placeholder for the summation variable
		t("="),
		i(2, "0"), -- Placeholder for the lower limit
		t("}^{"),
		i(3, "\\infty"), -- Placeholder for the upper limit
		t("} "),
		i(4, "c_"),
		t("_"),
		i(1), -- Reuse of the summation variable
		t(" (x-a)^"),
		i(1), -- Reuse of the summation variable
		i(0), -- Final cursor position
	}),

	-- Limit
	s("lim", {
		t("\\lim_{"),
		i(1, "n"), -- Placeholder for the variable approaching a limit
		t(" \\to "),
		i(2, "\\infty"), -- Placeholder for the value to which the variable is approaching
		t("} "),
	}),

	-- Limsup
	s("limsup", {
		t("\\limsup_{"),
		i(1, "n"), -- Placeholder for the variable
		t(" \\to "),
		i(2, "\\infty"), -- Placeholder for the value to which the variable is approaching
		t("} "),
	}),

	-- Product
	s("prod", {
		t("\\prod_{"),
		i(1, "n="), -- Placeholder for the variable
		i(2, "1"), -- Placeholder for the lower limit
		t("}^{"),
		i(3, "\\infty"), -- Placeholder for the upper limit
		t("} "),
		i(4, "VISUAL"), -- Placeholder for the content of the product
		i(0), -- Final cursor position
	}),

	-- Partial Derivative
	s("part", {
		t("\\frac{\\partial "),
		i(1, "V"), -- Placeholder for the function
		t("}{\\partial "),
		i(2, "x"), -- Placeholder for the variable
		t("} "),
		i(0), -- Final cursor position
	}),

	-- Square Root
	s("sq", {
		t("\\sqrt{"),
		i(1, "VISUAL"), -- Placeholder for the square root content
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Superscript 2 (^2)
	s("sr", {
		t("^2"),
	}),

	-- Superscript 3 (^3)
	s("cb", {
		t("^3"),
	}),
	-- To the power (simple exponent)
	s("td", {
		t("^"),
		t("{"),
		i(1), -- Placeholder for the power
		t("}"),
		i(0), -- Final cursor position
	}),

	-- To the power (with parentheses)
	s("rd", {
		t("^"),
		t("{("),
		i(1), -- Placeholder for the power
		t(")}"),
		i(0), -- Final cursor position
	}),

	-- Subscript
	s("__", {
		t("_"),
		t("{"),
		i(1), -- Placeholder for the subscript
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Infinity symbol
	s("ooo", {
		t("\\infty"),
	}),

	-- Multi-index notation
	s("rij", {
		t("("),
		i(1, "x"), -- Placeholder for the variable
		t("_"),
		i(2, "n"), -- Placeholder for the subscript
		t(")_{"),
		i(3, "n"), -- Placeholder for the index variable
		t("\\in"),
		i(4, "\\N"), -- Placeholder for the set (default is natural numbers)
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Less than or equal to
	s("<=", {
		t("\\le "),
	}),

	-- Greater than or equal to
	s(">=", {
		t("\\ge "),
	}),

	-- There exists (math context)
	s("EE", {
		t("\\exists "),
	}),
	-- For all symbol
	s("AA", {
		t("\\forall "),
	}),

	-- x_n (subscript n)
	s("xnn", {
		t("x_{n}"),
	}),

	-- y_n (subscript n)
	s("ynn", {
		t("y_{n}"),
	}),

	-- x_i (subscript i)
	s("xii", {
		t("x_{i}"),
	}),

	-- y_i (subscript i)
	s("yii", {
		t("y_{i}"),
	}),

	-- x_j (subscript j)
	s("xjj", {
		t("x_{j}"),
	}),

	-- y_j (subscript j)
	s("yjj", {
		t("y_{j}"),
	}),
	-- x_{n+1}
	s("xp1", {
		t("x_{n+1}"),
	}),

	-- x_{m}
	s("xmm", {
		t("x_{m}"),
	}),

	-- \R_0^+
	s("R0+", {
		t("\\R_0^+"),
	}),

	-- TikZ Plot
	s("plot", {
		t({ "\\begin{figure}[" }),
		i(1), -- Figure position (e.g., htpb)
		t({ "]", "\t\\centering", "\t\\begin{tikzpicture}", "\t\t\\begin{axis}[" }),
		t("xmin= "),
		i(2, "-10"), -- Placeholder for xmin
		t(", xmax= "),
		i(3, "10"), -- Placeholder for xmax
		t(", ymin= "),
		i(4, "-10"), -- Placeholder for ymin
		t(", ymax= "),
		i(5, "10"), -- Placeholder for ymax
		t({ ",", "\t\t\taxis lines = middle,", "\t\t]" }),
		t({ "", "\t\t\t\\addplot[domain=" }),
		i(2, "-10"), -- Reusing xmin for domain start
		t(":"),
		i(3, "10"), -- Reusing xmax for domain end
		t(", samples="),
		i(6, "100"), -- Placeholder for samples
		t({ "]{" }),
		i(7), -- Placeholder for the function to plot
		t("};"),
		t({ "", "\t\t\\end{axis}", "\t\\end{tikzpicture}" }),
		t({ "", "\t\\caption{" }),
		i(8), -- Placeholder for caption text
		t({ "}", "\t\\label{" }),
		i(9), -- Placeholder for label (can default to the same as caption)
		t({ "}", "\\end{figure}" }),
	}),

	-- TikZ Node
	s("nn", {
		t("\\node["),
		i(5), -- Placeholder for TikZ node options
		t("] ("),
		i(1), -- Placeholder for node name (cleaned version)
		i(2), -- Placeholder for extra information
		t(") "),
		i(3, "at ("),
		i(4, "0,0"), -- Placeholder for position
		t({ ") {" }),
		t("$"),
		i(1), -- Placeholder for content inside the node
		t({ "$};", "" }),
		i(0), -- Final cursor position
	}),
	-- \mathcal{}
	s("mcal", {
		t("\\mathcal{"),
		i(1), -- Placeholder for the argument of \mathcal
		t("}"),
		i(0), -- Final cursor position
	}),

	-- \ell (ell symbol)
	s("lll", {
		t("\\ell"),
	}),

	-- Nabla (del operator)
	s("nabl", {
		t("\\nabla "),
	}),

	-- Cross product symbol
	s("xx", {
		t("\\times "),
	}),

	-- \cdot (dot product)
	s("**", {
		t("\\cdot "),
	}),

	-- Norm (double bars)
	s("norm", {
		t("\\|"),
		i(1), -- Placeholder for the norm content
		t("\\|"),
		i(0), -- Final cursor position
	}),

	-- Trigonometric and logarithmic functions
	s("sin", { t("\\sin") }),
	s("cos", { t("\\cos") }),
	s("arccot", { t("\\arccot") }),
	s("cot", { t("\\cot") }),
	s("csc", { t("\\csc") }),
	s("ln", { t("\\ln") }),
	s("log", { t("\\log") }),
	s("exp", { t("\\exp") }),
	s("star", { t("\\star") }),
	s("perp", { t("\\perp") }),
	-- Definite Integral
	s("dint", {
		t("\\int_{"),
		i(1, "-\\infty"), -- Placeholder for the lower bound
		t("}^{"),
		i(2, "\\infty"), -- Placeholder for the upper bound
		t("} "),
		i(3, "VISUAL"), -- Placeholder for the integral content
		i(0), -- Final cursor position
	}),

	-- Common math functions: arcsin, arccos, arctan, arccot, arccsc, arcsec, pi, zeta, int
	s("arcsin", { t("\\arcsin") }),
	s("arccos", { t("\\arccos") }),
	s("arctan", { t("\\arctan") }),
	s("arccot", { t("\\arccot") }),
	s("arccsc", { t("\\arccsc") }),
	s("arcsec", { t("\\arcsec") }),
	s("pi", { t("\\pi") }),
	s("zeta", { t("\\zeta") }),
	s("int", { t("\\int") }),

	-- Arrow (to)
	s("->", {
		t("\\to "),
	}),

	-- Leftrightarrow
	s("<->", {
		t("\\leftrightarrow "),
	}),

	-- Mapsto
	s("!>", {
		t("\\mapsto "),
	}),

	-- Inverse (superscript -1)
	s("invs", {
		t("^{-1}"),
	}),
	-- Integral
	s("dint", {
		t("\\int_{"),
		i(1, "-\\infty"), -- Placeholder for lower limit (default is -∞)
		t("}^{"),
		i(2, "\\infty"), -- Placeholder for upper limit (default is ∞)
		t("} "),
		i(3, "VISUAL"), -- Placeholder for the integral's content
		i(0), -- Final cursor position
	}),

	-- Trigonometric and special math functions
	s("arcsin", { t("\\arcsin") }),
	s("arccos", { t("\\arccos") }),
	s("arctan", { t("\\arctan") }),
	s("arccot", { t("\\arccot") }),
	s("arccsc", { t("\\arccsc") }),
	s("arcsec", { t("\\arcsec") }),
	s("pi", { t("\\pi") }),
	s("zeta", { t("\\zeta") }),
	s("int", { t("\\int") }),

	-- Arrow symbols
	s("->", {
		t("\\to "),
	}),

	s("<->", {
		t("\\leftrightarrow"),
	}),

	s("!>", {
		t("\\mapsto "),
	}),

	-- Inverse notation
	s("invs", {
		t("^{-1}"),
	}),

	-- Complement (superscript c)
	s("compl", {
		t("^{c}"),
	}),

	-- Set minus
	s("\\\\", {
		t("\\setminus"),
	}),

	-- Much greater than
	s(">>", {
		t("\\gg"),
	}),

	-- Much less than
	s("<<", {
		t("\\ll"),
	}),

	-- Similar to symbol
	s("~~", {
		t("\\sim "),
	}),

	-- Set notation
	s("set", {
		t("\\{"),
		i(1), -- Placeholder for set elements
		t("\\}"),
		i(0), -- Final cursor position
	}),

	-- Mid (divides) symbol
	s("||", {
		t(" \\mid "),
	}),
	-- Subset Symbol
	s("cc", {
		t("\\subset "),
	}),

	-- Not in Symbol
	s("notin", {
		t("\\not\\in "),
	}),

	-- In Symbol
	s("inn", {
		t("\\in "),
	}),

	-- Natural Numbers Symbol (\N)
	s("NN", {
		t("\\N"),
	}),

	-- Intersection Symbol (\cap)
	s("Nn", {
		t("\\cap "),
	}),

	-- Union Symbol (\cup)
	s("UU", {
		t("\\cup "),
	}),

	-- Big Union Symbol (\bigcup)
	s("uuu", {
		t("\\bigcup_{"),
		i(1, "i \\in "),
		i(2, "I"), -- Placeholder for the set
		t("} "),
		i(0), -- Final cursor position
	}),

	-- Big Intersection Symbol (\bigcap)
	s("nnn", {
		t("\\bigcap_{"),
		i(1, "i \\in "),
		i(2, "I"), -- Placeholder for the set
		t("} "),
		i(0), -- Final cursor position
	}),
	-- Empty Set (\O)
	s("OO", {
		t("\\O"),
	}),

	-- Real Numbers (\R)
	s("RR", {
		t("\\R"),
	}),

	-- Rational Numbers (\Q)
	s("QQ", {
		t("\\Q"),
	}),

	-- Integers (\Z)
	s("ZZ", {
		t("\\Z"),
	}),

	-- Normal Subgroup (\triangleleft)
	s("<!", {
		t("\\triangleleft "),
	}),

	-- Diamond Symbol (\diamond)
	s("<>", {
		t("\\diamond "),
	}),

	-- Text Subscript (_\text{...})
	s("sts", {
		t("_\\text{"),
		i(1), -- Placeholder for the subscript text
		t("} "),
		i(0), -- Final cursor position
	}),

	-- Text (\text{...})
	s("tt", {
		t("\\text{"),
		i(1), -- Placeholder for the text
		t("}"),
		i(0), -- Final cursor position
	}),
	-- Cases Environment
	s("case", {
		t({ "\\begin{cases}", "\t" }),
		i(1), -- Placeholder for the cases content
		t({ "", "\\end{cases}" }),
	}),

	-- SI Unit (\SI{}{})
	s("SI", {
		t("\\SI{"),
		i(1), -- Placeholder for the value
		t("}{"),
		i(2), -- Placeholder for the unit
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Big Function
	s("bigfun", {
		t({ "\\begin{align*}", "\t" }),
		i(1), -- Placeholder for function name
		t(": "),
		i(2), -- Placeholder for domain
		t(" &\\longrightarrow "),
		i(3), -- Placeholder for codomain
		t({ " \\\\", "\t" }),
		i(4), -- Placeholder for the variable
		t(" &\\longmapsto "),
		i(1), -- Placeholder for function name
		t("("),
		i(4), -- Placeholder for the variable
		t(") = "),
		i(0), -- Placeholder for the function definition
		t({ "", "\\end{align*}" }),
	}),

	-- Column Vector (pmatrix)
	s("cvec", {
		t("\\begin{pmatrix} "),
		i(1, "x"), -- Placeholder for the variable
		t("_"),
		i(2, "1"), -- Placeholder for the first index
		t("\\\\ \\vdots \\\\ "),
		i(1, "x"), -- Reuse of the variable
		t("_"),
		i(2, "n"), -- Placeholder for the last index
		t(" \\end{pmatrix}"),
	}),

	-- Bar (\overline{})
	s("bar", {
		t("\\overline{"),
		i(1), -- Placeholder for the content inside the bar
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Bar for single characters like xbar or ybar
	s({ trig = "([a-zA-Z])bar", regTrig = true }, {
		f(function(_, snip)
			local char = snip.captures[1]
			return "\\overline{" .. char .. "}"
		end),
	}),
	-- Hat (manual trigger)
	s("hat", {
		t("\\hat{"),
		i(1), -- Placeholder for the content
		t("}"),
		i(0), -- Final cursor position
	}),

	-- Hat for single characters like xhat or yhat
	s({ trig = "([a-zA-Z])hat", regTrig = true }, {
		f(function(_, snip)
			local char = snip.captures[1]
			return "\\hat{" .. char .. "}"
		end),
	}),

	-- Let Omega statement
	s("letw", {
		t("Let $\\Omega \\subset \\C$ be open."),
	}),

	-- \mathbb{H} (Hilbert Space or Quaternions)
	s("HH", {
		t("\\mathbb{H}"),
	}),

	-- \mathbb{D} (Disk or domain)
	s("DD", {
		t("\\mathbb{D}"),
	}),
}
