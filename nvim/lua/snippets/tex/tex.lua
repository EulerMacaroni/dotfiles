-- LaTeX Snippets
-- TODO:
-- set options for matrix and table snippets (either auto generate or user input)
-- fix integral snippet
-- clean up snippets
--- test 
---- 
--[
-- Setup: LuaSnip imports, define conditions/additional functions for function/dynamic nodes.
--]
local line_begin = require("luasnip.extras.conditions.expand").line_begin
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })
local postfix = require("luasnip.extras.postfix").postfix
local tex = require("snippets.tex.utils").conditions -- conditions 
local make_condition = require("luasnip.extras.conditions").make_condition

-- chained conditions 
local in_preamble = make_condition(tex.in_preamble)
local in_bullets = make_condition(tex.in_bullets)

-- condition envs
-- global p! functions from UltiSnips
local function env(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

local function tikz()
	return env("tikzpicture")
end

-- brackets
local brackets = {
	a = { "\\langle", "\\rangle" },
	A = { "\\rAngle", "\\rAngle" },
	b = { "[", "]" },
	B = { "\\lBrack", "\\rBrack" },
	c = { "\\{", "\\}" },
	m = { "|", "|" },
	p = { "(", ")" },
}

local reference_snippet_table = {
    a = "auto",
    c = "c",
    C = "C",
    e = "eq",
    r = ""
}

-- util
local function isempty(s) --util
	return s == nil or s == ""
end

-- dynamic stuff
-- LFG tables and matrices work
local tab = function(_, snip)
	local rows = tonumber(snip.captures[1])
	local cols = tonumber(snip.captures[2])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
		if j == 1 then
			table.insert(nodes, t({ "\\midrule", "" }))
		end
	end
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- yes this is a ripoff
-- thanks L3MON4D3!
local mat = function(_, snip)
	local rows = tonumber(snip.captures[2])
	local cols = tonumber(snip.captures[3])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
	end
	-- fix last node.
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- update for cases
local case = function(_, snip)
	local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
	local cols = 2 -- fix to 2 cols
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
	end
	-- fix last node.
    table.remove(nodes, #nodes)
	return sn(nil, nodes)
end

-- add table/matrix/case row
local tr = function(_, snip)
	local cols = tonumber(snip.captures[1])
	local nodes = {}
	local ins_indx = 1
	table.insert(nodes, r(ins_indx, "1", i(1)))
	ins_indx = ins_indx + 1
	for k = 2, cols do
		table.insert(nodes, t(" & "))
		table.insert(nodes, r(ins_indx, tostring(k), i(1)))
		ins_indx = ins_indx + 1
	end
	table.insert(nodes, t({ "\\\\", "" }))
	-- fix last node.
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- integral functions
local int1 = function(_, snip)
	local vars = tonumber(snip.captures[1])
	local nodes = {}
	for j = 1, vars do
		table.insert(nodes, t("\\int_{"))
		table.insert(nodes, r(2 * j - 1, "lb" .. tostring(j), i(1)))
		table.insert(nodes, t("}^{"))
		table.insert(nodes, r(2 * j, "ub" .. tostring(j), i(1)))
		table.insert(nodes, t("} "))
	end
	return sn(nil, nodes)
end

local int2 = function(_, snip)
	local vars = tonumber(snip.captures[1])
	local nodes = {}
	for j = 1, vars do
		table.insert(nodes, t(" \\dd "))
		table.insert(nodes, r(j, "var" .. tostring(j), i(1)))
	end
	return sn(nil, nodes)
end

local generate_fraction = function (_, snip)
    local stripped = snip.captures[1]
    local depth = 0
    local j = #stripped
    while j >= 1 do
        local c = stripped:sub(j, j)
        if c == "(" then
            depth = depth + 1
        elseif c == ")" then
            depth = depth - 1
        end
        if depth == 0 then
            break
        end
        j = j - 1
    end
    return sn(nil,
        fmta([[
        <>\frac{<>}{<>}
        ]],
        { t(stripped:sub(1, j-1)), t(stripped:sub(j)), i(1)}))
end

-- visual util to add insert node
-- thanks ejmastnak!
local get_visual = function(_, parent)
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
end

-- jokar arc of luasnip breaking
local generate_label_snode = function(label_head, xargs)
	if xargs == false then
		delims = { "\\label{", "}" }
	else
		delims = { "[", "]" }
	end
	if isempty(label_head) then
		return sn(nil,
                    fmta([[
                    \label{<>}
                    ]],
                    { i(1) }))
	else
		return sn(nil,
                    fmta([[
                    <><>:<><>
                    ]],
                    { t(delims[1]), t(label_head), i(1), t(delims[2]) }))
	end
end

-- return arbitrary snip captures + string concatenate
local get_capture = function(_, snip, user_arg1, user_arg2, user_arg3)
	-- define arguments
	idx = user_arg1 or 1
	pre = user_arg2 or ""
	post = user_arg3 or ""
	return snip.captures[idx]
end

--[
-- Snippets go here
--]

local M = {
	--[
	-- Templates: Stuff for lecture notes, homeworks, and draft documents
	--]
	s({ trig = "texdoc", name = "new tex doc", dscr = "Create a general new tex document" },
	fmta([[ 
    \documentclass{article}
    \usepackage{iftex}
    \ifluatex
    \directlua0{
    pdf.setinfo (
        table.concat (
        {
           "/Title (<>)",
           "/Author (Evelyn Koo)",
           "/Subject (<>)",
           "/Keywords (<>)"
        }, " "
        )
    )
    }
    \fi
    \usepackage{graphicx}
    \graphicspath{{figures/}}
    \usepackage[lecture]{random}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\textsc{Evelyn Koo}}
    \chead{\textsc{<>}}
    \lhead{<>}
    \cfoot{\thepage}
    \begin{document}
    \title{<>}
    \author{Evelyn Koo}
    \date{<>}
    \maketitle
    \tableofcontents
    \section*{<>}
    \addcontentsline{toc}{section}{<>}
    <>
    \subsection*{Remarks}
    <>
    \end{document}
    ]],
	{ i(3), i(2), i(7), i(1), rep(2), rep(3), i(4), i(5), rep(5), i(6), i(0) }),
    { condition = tex.in_preamble, show_condition = tex.in_preamble }
	),
	s({ trig = "hwtex", name = "texdoc for hw", dscr = "tex template for my homeworks" },
	fmta([[ 
    \documentclass{article}
    \usepackage{iftex}
    \ifluatex
    \directlua0{
    pdf.setinfo (
        table.concat (
        {
           "/Title (<> <>)",
           "/Author (Evelyn Koo)",
           "/Subject (<>)",
           "/Keywords (<>)"
        }, " "
        )
    )
    }
    \fi
    \usepackage{graphicx}
    \graphicspath{{figures/}}
    \usepackage[lecture]{random}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\textsc{Evelyn Koo}}
    \chead{\textsc{Homework <>}}
    \lhead{<>}
    \cfoot{\thepage}
    \begin{document}
    \homework[<>]{<>}{<>}
    <>
    \end{document}
    ]],
	{ t("Homework"), i(1), i(2), i(3), rep(1), rep(2), t(os.date("%d-%m-%Y")), rep(2), rep(1), i(0) }),
	{ condition = tex.in_preamble, show_condition = tex.in_preamble }),
	s({ trig = "texbook", name = "tex book", dscr = "make a new tex book", hidden = true },
	fmta([[
    \documentclass[twoside]{book}
    \usepackage[utf8]{inputenc}
    \usepackage{makeidx}
    \usepackage{tocbibind}
    \usepackage[totoc]{idxlayout} 
    \input{pre/preamble.tex}

    \begin{document}
    <>
    \end{document}
    ]],
	{ i(1) }),
	{ condition = tex.in_preamble, show_condition = tex.in_preamble }),
	s({ trig = "draft", name = "draft", dscr = "draft", hidden = true },
	fmta([[ 
    \documentclass{article}
    \usepackage{random}
    \begin{document}
    <>
    \end{document}
    ]],
	{ i(0) }),
	{ condition = tex.in_preamble, show_condition = tex.in_preamble }
	),
	s({ trig = "sftex", name = "subfile", dscr = "subfile template" },
	fmta([[
    \documentclass[<>]{subfiles}
    \begin{document}
    <>
    <>
    \end{document}
    ]],
	{ i(1, "./main.tex"), c(2, {i(1), fmta([[
    \lecture[<>]{<>}
    ]], {t(os.date("%d-%m-%Y")), i(1)})}), i(0) }),
    { condition = tex.in_preamble, show_condition = tex.in_preamble }
	),

	-- [
	-- Introductory Stuff: e.g. table of contents, packages, other setup Stuff
	-- think templates but modular
	-- ]
	s({ trig = "atoc", name = "add toc", dscr = "add this to toc line" },
	fmta([[ 
    \addcontentsline{toc}{<>}{<>}
    <>
    ]],
	{ i(1, "section"), i(2, "content"), i(0) })
	),

	--[
	-- Semantic Snippets: sections n stuff, mostly stolen from markdown
	--]

	-- sections from LaTeX
	s({ trig = "#", hidden = true, priority = 250 },
	fmta([[
    \section{<>}<>
    <>]],
    { i(1), c(2, { t(""), generate_label_snode("sec", false) }), i(0) })
	),
	s({ trig = "#*", hidden = true, priority = 250 },
    fmta([[
    \section*{<>}<>
    <>]],
	{ i(1), c(2, { t(""), generate_label_snode("sec", false)}), i(0) })
	),
	s({ trig = "##", hidden = true, priority = 500 },
	fmta([[
    \subsection{<>}<>
    <>]],
	{ i(1), c(2, { t(""), generate_label_snode("subsec", false)}), i(0) })
	),
	s({ trig = "##*", hidden = true, priority = 500 },
    fmta([[
    \subsection*{<>}<>
    <>]],
	{ i(1), c(2, { t(""), generate_label_snode("subsec", false)}), i(0) })
	),
	s({ trig = "###", hidden = true, priority = 1000 },
    fmta([[ 
    \subsubsection{<>}
    <>]],
	{ i(1), i(0) })
	),
	s({ trig = "###*", hidden = true, priority = 1000 },
    fmta([[ 
    \subsubsection*{<>}
    <>]],
	{ i(1), i(0) })
	),

	-- custom sections
	s({ trig = "#l", name = "lecture", dscr = "fancy section header - lecture #", hidden = true },
	fmta([[ 
    \lecture[<>]{<>}
    <>]],
	{ t(os.date("%Y-%m-%d")), i(1), i(0) })
	),
	s({ trig = "#ch", name = "chap", dscr = "fancy section header - chapter #", hidden = true },
	fmta([[ 
    \bookchap[<>]{<>}{<>}
    <>]],
	{ t(os.date("%d-%m-%Y")), i(1, "dscr"), i(2, "\\thesection"), i(0) })
	),
	s({ trig = "#f", name = "fancy section", dscr = "fancy section header - vanilla", hidden = true },
	fmta([[ 
    \fancysec[<>]{<>}{<>}
    <>]],
	{ t(os.date("%d-%m-%Y")), i(1, "dscr"), i(2, "title"), i(0) })
	),

	-- links images figures
	s({ trig = "!l", name = "link", dscr = "Link reference", hidden = true },
    fmta([[
    \href{<>}{\color{<>}<>}<>
    ]],
    { i(1, "link"), i(3, "blue"), i(2, "title"), i(0) })
	),
	s({ trig = "!i", name = "image", dscr = "Image (no caption, no float)" },
	fmta([[ 
    \begin{Center}
    \includegraphics[width=<>\textwidth]{<>}
    \end{Center}
    <>]],
	{ i(1, "0.5"), i(2), i(0) })
	),
	s({ trig = "!f", name = "figure", dscr = "Float Figure" },
	fmta([[ 
    \begin{figure}[<>] 
    <>
    \end{figure}]],
	{ i(1, "htb!"), i(0) })
	),
	s({ trig = "gr", name = "figure image", dscr = "float image" },
	fmta([[
    \centering
    \includegraphics[width=<>\textwidth]{<>}\caption{<>}<>]],
	{ i(1, "0.5"), i(2), i(3), i(0) })
	),

	-- code highlighting
	s({ trig = "qw", name = "inline code", dscr = "inline code, ft escape" },
	fmta([[
    \mintinline{<>}<>
    ]],
	{ i(1, "text"), c(2, { sn(nil, { t("{"), i(1), t("}") }), sn(nil, { t("|"), i(1), t("|") }) }) })
	),
	s({ trig = "qe", name = "code", dscr = "Code with minted." },
	fmta([[ 
    \begin{minted}{<>}
    <>
    \end{minted}
    <>]],
	{ i(1, "python"), i(2), i(0) })
	),
	s({ trig = "mp", name = "minipage", dscr = "create minipage env" }, -- choice node
	fmta([[
    \begin{minipage}{<>\textwidth}
    <>
    \end{minipage}]],
	{ c(1, { t("0.5"), t("0.33"), i(nil) }), i(0) })
	),

	-- labels/refs
    autosnippet({ trig='alab', name='label', dscr='add a label'},
    fmta([[
    \label{<>:<>}
    ]],
    { i(1), i(0) })),
    autosnippet({ trig='([acCer])ref', name='(acC|eq)?ref', dscr='add a reference (with autoref, cref, eqref)', trigEngine="pattern", hidden = true},
    fmta([[
    \<>ref{<>:<>}
    ]],
    { f(function (_, snip)
        return reference_snippet_table[snip.captures[1]]
    end),
    i(1), i(0) }),
    { condition = tex.in_text, show_condition = tex.in_text }),

	--[
	-- Environments
	--]
	-- generic
	s({ trig = "beg", name = "begin env", dscr = "begin/end environment" },
	fmta([[
    \begin{<>}
    <>
    \end{<>}
    ]],
	{ i(1), i(0), rep(1) })
	),

	-- Bullet Points
	s({ trig = "-i", name = "itemize", dscr = "bullet points (itemize)" },
	fmta([[ 
    \begin{itemize}
    \item <>
    \end{itemize}]],
	{ c(1, { i(0), 
        sn(nil, fmta([[
                [<>] <>
                ]],
                { i(1), i(0) }))
        })
    })
	),
	s({ trig = "-e", name = "enumerate", dscr = "numbered list (enumerate)" },
	fmta([[ 
    \begin{enumerate}<>
    \item <>
    \end{enumerate}
    ]],
	{c(1, { t(""),
        sn(nil, fmta([[
            [label=<>]
            ]],
			{ c(1, { t("(\\alph*)"), t("(\\roman*)"), i(1) }) })),
		}),
	c(2, { i(0),
        sn(nil, fmta([[
                [<>] <>
                ]],
                { i(1), i(0) }))
        }),
	})
	),
	-- generate new bullet points
	autosnippet({ trig = "--", hidden = true }, { t("\\item") },
	{ condition = in_bullets * line_begin, show_condition = in_bullets * line_begin }
	),
	autosnippet({ trig = "!-", name = "bp custom", dscr = "bullet point" },
	fmta([[ 
    \item [<>]<>
    ]],
	{ i(1), i(0) }),
	{ condition = in_bullets * line_begin, show_condition = in_bullets * line_begin }
	),

	-- tables/matrices
	s({ trig = "tab(%d+)x(%d+)", trigEngine="pattern", name = "test for tabular", dscr = "test", hidden = true },
	fmta([[
    \begin{tabular}{@{}<>@{}}
    \toprule
    <>
    \bottomrule
    \end{tabular}
    ]],
	{ f(function(_, snip)
        return string.rep("c", tonumber(snip.captures[2]))
    end), d(1, tab) })
	),
    s({trig = "([bBpvV])mat(%d+)x(%d+)([ar])", name = "[bBpvV]matrix", dscr = "matrices", trigEngine="pattern", hidden = true},
	fmta([[
    \begin{<>}<>
    <>
    \end{<>}]],
	{f(function(_, snip)
        return snip.captures[1] .. "matrix"
    end),
    f(function(_, snip)
        if snip.captures[4] == "a" then
            out = string.rep("c", tonumber(snip.captures[3]) - 1)
            return "[" .. out .. "|c]"
        end
        return ""
    end),
    d(1, mat),
    f(function(_, snip)
        return snip.captures[1] .. "matrix"
    end)
    }),
	{ condition = tex.in_math, show_condition = tex.in_math }
	),
    -- generate table row
    s({ trig='tr(%d)', name='table row', dscr='table row', trigEngine="pattern", hidden=true},
    fmta([[
    <>,
    ]],
    { d(1, tr) }
    )),

	-- etc
	s({ trig = "sol", name = "solution", dscr = "solution box for homework" },
	fmta([[ 
    \begin{solution}
    <>
    \end{solution}
    ]],
	{ i(0) })
	),

	--[
	-- Math Snippets - Environments/Setup Commands
	--]

    -- Math modes
    autosnippet({ trig = "mk", name = "$..$", dscr = "inline math" },
	fmta([[
    $<>$<>
    ]],
    { i(1), i(0) })
	),
    autosnippet({ trig = "dm", name = "\\[...\\]", dscr = "display math" },
	fmta([[ 
    \[ 
    <>
    \]
    <>]],
	{ i(1), i(0) }),
    { condition = line_begin, show_condition = line_begin }
	),
    autosnippet({ trig = "ali", name = "align(|*|ed)", dscr = "align math" },
	fmta([[ 
    \begin{align<>}
    <>
    .\end{align<>}
    ]],
    { c(1, {t("*"), t(""), t("ed")}), i(2), rep(1) }), -- in order of least-most used
	{ condition = line_begin, show_condition = line_begin }
	),
    autosnippet({ trig='==', name='&= align', dscr='&= align'},
    fmta([[
    &<> <> \\
    ]],
    { c(1, {t("="), t("\\leq"), i(1)}), i(2) }
    ), { condition = tex.in_align, show_condition = tex.in_align }),

	autosnippet({ trig = "gat", name = "gather(|*|ed)", dscr = "gather math" },
	fmta([[ 
    \begin{gather<>}
    <>
    .\end{gather<>}
    ]],
	{ c(1, {t("*"), t(""), t("ed")}), i(2), rep(1) }),
	{ condition = line_begin, show_condition = line_begin }
	),
	autosnippet({ trig = "eqn", name = "equation(|*)", dscr = "equation math" },
	fmta([[
    \begin{equation<>}<>
    <>
    .\end{equation<>}
    ]],
	{ c(1, {t("*"), t("")}), c(2, {t(""), fmta([[\tag{<>}<>]], {i(1), i(0)})}), i(3), rep(1) }),
	{ condition = line_begin, show_condition = line_begin }
	),
    autosnippet({ trig = "(%d?)cases", name = "cases", dscr = "cases", trigEngine="pattern", hidden = true },
    fmta([[
    \begin{cases}
    <>
    .\end{cases}
    ]],
	{ d(1, case) }),
    { condition = tex.in_math, show_condition = tex.in_math }
	),

	-- delimiters
	s({ trig = "lr", name = "left right", dscr = "left right" },
	fmta([[
    \left(<>\right)<>
    ]],
    { i(1), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "lr([aAbBcmp])", name = "left right", dscr = "left right delimiters", trigEngine="pattern", hidden=true },
	fmta([[
    \left<> <> \right<><>
    ]],
    {f(function(_, snip)
        cap = snip.captures[1]
        if brackets[cap] == nil then
            cap = "p"
        end -- set default to parentheses
        return brackets[cap][1]
    end),
    d(1, get_visual),
    f(function(_, snip)
        cap = snip.captures[1]
        if brackets[cap] == nil then
            cap = "p"
        end
        return brackets[cap][2]
    end),
    i(0)}),
    { condition=tex.in_math, show_condition=tex.in_math }
	),

	-- operators, symbols
	autosnippet({ trig = "//", name = "fraction", dscr = "fraction (autoexpand)" },
    fmta([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "((\\d+)|(\\d*)(\\\\)?([A-Za-z]+)((\\^|_)(\\{\\d+\\}|\\d))*)\\/", name = "fraction 2", dscr = "fraction autoexpand 2", trigEngine="ecma", hidden = true },
	fmta([[
    \frac{<>}{<>}<>
    ]],
	{ f(get_capture, {}, { user_args = { 1 } }), i(1), i(0) }),
	{ condition=tex.in_math, show_condition=tex.in_math }
	),
    autosnippet({ trig='(^.*\\))/', name='fraction 3', dscr='fraction 3', trigEngine="ecma", hidden=true},
    { d(1, generate_fraction) },
    { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet({ trig = "!!+", priority = 500 }, { t("\\bigoplus") }, { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet({ trig = "!!*", priority = 500 }, { t("\\bigotimes") }, { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet({ trig = "Oo", priority = 50 }, { t("\\circ") }, { condition=tex.in_math, show_condition=tex.in_math }),

	-- sub super scripts
	autosnippet({ trig = "([%a%)%]%}])(%d)", trigEngine="pattern", name = "auto subscript", dscr = "hi" },
	fmta([[
    <>_<>
    ]],
	{ f(get_capture, {}, { user_args = { 1 } }), f(get_capture, {}, { user_args = { 2 } }) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({trig = "([%a%)%]%}])_(%d%d)", trigEngine="pattern", name = "auto subscript 2", dscr = "auto subscript for 2+ digits"},
	fmta([[
    <>_{<>}
    ]],
    { f(get_capture, {}, { user_args = { 1 } }), f(get_capture, {}, { user_args = { 2 } }) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
    -- short vers.
	autosnippet("xnn", { t("x_n") }, { condition=tex.in_math }),
	autosnippet("xii", { t("x_i") }, { condition=tex.in_math }),
	autosnippet("xjj", { t("x_j") }, { condition=tex.in_math }),
	autosnippet("ynn", { t("y_n") }, { condition=tex.in_math }),
	autosnippet("yii", { t("y_i") }, { condition=tex.in_math }),
	autosnippet("yjj", { t("y_j") }, { condition=tex.in_math }),
	autosnippet({ trig = "sr", wordTrig = false }, { t("^2") }, { condition=tex.in_math }),
	autosnippet({ trig = "cb", wordTrig = false }, { t("^3") }, { condition=tex.in_math }),
	autosnippet({ trig = "compl", wordTrig = false }, { t("^{c}") }, { condition=tex.in_math }),
	autosnippet({ trig = "vtr", wordTrig = false }, { t("^{T}") }, { condition=tex.in_math }),
	autosnippet({ trig = "inv", wordTrig = false }, { t("^{-1}") }, { condition=tex.in_math }),

	-- stuff i need to do calculus
	autosnippet("dd", { t("\\dd") }, { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet("nabl", { t("\\nabla") }, { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet("grad", { t("\\grad") }, { condition=tex.in_math, show_condition=tex.in_math }),
	autosnippet({ trig = "lim", name = "lim(sup|inf)", dscr = "lim(sup|inf)" },
	fmta([[ 
    \lim<><><>
    ]],
	{c(1, { t(""), t("sup"), t("inf") }),
	c(2, { t(""), fmta([[_{<> \to <>}]], { i(1, "n"), i(2, "\\infty") }) }),
	i(0)}),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	-- autosnippet(
	-- 	{ trig = "part", name = "partial derivative", dscr = "partial derivative" },
	-- 	fmt(
	-- 		[[ 
 --    \frac{\ddp <>}{\ddp <>}<>
 --    ]],
	-- 		{ i(1, "V"), i(2, "x"), i(0) },
	-- 		{ delimiters = "<>" }
	-- 	),
	-- 	{ condition=tex.in_math, show_condition=tex.in_math }
	-- ),
	autosnippet({ trig = "dint", name = "integrals", dscr = "integrals but cooler" },
    fmta([[
    \<>int_{<>}^{<>} <> <> <>
    ]],
	{ c(1, { t(""), t("o") }), i(2, "-\\infty"), i(3, "\\infty"), i(4), t("\\dd"), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "(%d)int", name = "multi integrals", dscr = "please work", trigEngine="pattern", hidden = false },
	fmta([[ 
    <> <> <> <>
    ]],
	{ c(1, {
        fmta([[
        \<><>nt_{<>}
        ]],
	    { c(1, { t(""), t("o") }),
		f(function(_, parent, snip)
            inum = tonumber(parent.parent.captures[1]) -- this guy's lineage looking like a research lab's
            res = string.rep("i", inum)
            return res
        end), i(2) }),
	  d(nil, int1)}),
	i(2), d(3, int2), i(0)}),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "sum", name = "summation", dscr = "summation" },
    fmta([[
    \sum<> <>
    ]],
    { c(1, {fmta([[_{<>}^{<>}]], {i(1, "i = 0"), i(2, "\\infty")}), t("")}), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "prod", name = "product", dscr = "summation" },
    fmta([[
    \prod<> <>
    ]],
	{ c(1, {fmta([[_{<>}^{<>}]], {i(1, "i = 0"), i(2, "\\infty")}), t("")}), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "cprod", name = "product", dscr = "summation" },
    fmta([[
    \coprod<> <>
    ]],
	{ c(1, {fmta([[_{<>}^{<>}]], {i(1, "i = 0"), i(2, "\\infty")}), t("")}), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),

	-- quantifiers and cs70 n1 stuff
	autosnippet("||", { t("\\divides") }, { condition=tex.in_math }),
	autosnippet("!|", { t("\\notdivides") }, { condition=tex.in_math, show_condition=tex.in_math }),

	-- sets
	autosnippet({ trig = "set", name = "set", dscr = "set" }, -- overload with set builders notation because analysis and algebra cannot agree on a singular notation
	fmta([[
    \{<>\}<>
    ]],
	{ c(1, { r(1, ""), sn(nil, { r(1, ""), t(" \\mid "), i(2) }), sn(nil, { r(1, ""), t(" \\colon "), i(2) })}), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
    ),
    autosnippet({ trig = "nnn", name = "bigcap", dscr = "bigcaps" },
    fmta([[
    \bigcap<> <>
    ]],
	{ c(1, {fmta([[_{<>}^{<>}]], {i(1, "i = 0"), i(2, "\\infty")}), t("")}), i(0) }),
	{ condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet({ trig = "uuu", name = "bigcup", dscr = "bigcaps" },
    fmta([[
    \bigcup<> <>
    ]],
	{ c(1, {fmta([[_{<>}^{<>}]], {i(1, "i = 0"), i(2, "\\infty")}), t("")}), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),

	-- counting, probability
	autosnippet({ trig = "bnc", name = "binomial", dscr = "binomial (nCR)" },
    fmta([[
    \binom{<>}{<>}<>
    ]],
    { i(1), i(2), i(0) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),

	-- etc: utils and stuff
	autosnippet({ trig = "([clvda])%.", trigEngine="pattern", name = "dots", dscr = "generate some dots" },
    fmta([[
    \<>dots
    ]],
    { f(get_capture, {}, { user_args = { 1 } }) }),
    { condition=tex.in_math, show_condition=tex.in_math }
	),
	autosnippet("lb", { t("\\\\") }, { condition=tex.in_math }),
	autosnippet("tcbl", { t("\\tcbline") }),

    --- tikz 
    s({ trig='tn', name='tikz node', dscr='tikz node'},
    fmta([[
    \node[<><>] (<>) at <> {<>};
    ]],
    { i(1, "style"), c(2, {t(""), fmta([[label=<>]], {i(1)})}), i(3, "node ref"), i(4, "coord"), i(5, "") }
    ), { condition = tikz, show_condition = tikz }),
}


-- {
-- Text Mode Scaffolding Snippets
-- }

local single_command_snippet = require("snippets.tex.utils").scaffolding.single_command_snippet

local single_command_specs = {
	sec = {
		context = {
			name = "section",
			dscr = "add a section",
		},
		command = [[\section]],
		ext = { label = true, short = "sec" },
	},
	sq = {
		context = {
			name = "enquote*",
			dscr = "single quotes",
		},
		command = [[\enquote*]],
	},
	qq = {
		context = {
			name = "enquote",
			dscr = "double quotes",
		},
		command = [[\enquote]],
	},
	bf = {
		context = {
			name = "textbf",
			dscr = "bold text",
			hidden = true,
		},
		command = [[\textbf]],
	},
	it = {
		context = {
			name = "textit",
			dscr = "italic text",
			hidden = true,
		},
		command = [[\textit]],
	},
	sc = {
		context = {
			name = "textsc",
			dscr = "small caps",
			hidden = true,
		},
		command = [[\textsc]],
	},
	tu = {
		context = {
			name = "underline (text)",
			dscr = "underlined text in non-math mode",
			hidden = true,
		},
		command = [[\underline]],
	},
	tov = {
		context = {
			name = "overline (text)",
			dscr = "overline text in non-math mode",
			hidden = true,
		},
		command = [[\overline]],
	},
	pac = {
		context = {
			name = "usepackage",
			dscr = "usepackage (with option)",
		},
		command = [[\usepackage]],
		opt = { condition = tex,in_preamble, show_condition = tex.in_preamble },
		ext = { choice = true },
	},
}

local single_command_snippets = {}
for k, v in pairs(single_command_specs) do
	table.insert(
		single_command_snippets,
		single_command_snippet(
			vim.tbl_deep_extend("keep", { trig = k }, v.context),
			v.command,
			v.opt or { condition = tex.in_text },
			v.ext or {}
		)
	)
end
vim.list_extend(M, single_command_snippets)

-- envs
local env_snippet = require("snippets.tex.utils").scaffolding.env_snippet

local env_specs = {
	mint = {
		context = {
			name = "minted",
			dscr = "create minted environment",
		},
		command = [[minted]],
		ext = { opt = true, delim = "c" },
	},
    swt = {
		context = {
			name = "shownto",
			dscr = "multiaudience shownto",
		},
		command = [[shownto]],
		ext = { opt = true, delim = "c" },
	},

}

local env_snippets = {}
for k, v in pairs(env_specs) do
	table.insert(
		env_snippets,
		env_snippet(
			vim.tbl_deep_extend("keep", { trig = k }, v.context),
			v.command,
			{ condition = tex.in_text },
			v.ext or {}
		)
	)
end
vim.list_extend(M, env_snippets)

-- tcolorboxes *sigh*
local tcolorbox_snippet = require("snippets.tex.utils").scaffolding.tcolorbox_snippet

local tcolorbox_specs = {
	adef = {
		context = {
			name = "definition",
			dscr = "add defintion box",
		},
		command = [[def]],
	},
	aex = {
		context = {
			name = "example",
			dscr = "add example box",
		},
		command = [[ex]],
	},
    exr = {
		context = {
			name = "exercise",
			dscr = "add exercise box",
		},
		command = [[exer]],
	},
	athm = {
		context = {
			name = "theorem",
			dscr = "add theorem box",
		},
		command = [[thm]],
	},
	lem = {
		context = {
			name = "lemma",
			dscr = "add lemma box",
		},
		command = [[lem]],
	},
	acr = {
		context = {
			name = "corollary",
			dscr = "add corollary box",
		},
		command = [[cor]],
	},
	aprop = {
		context = {
			name = "proposition",
			dscr = "add proposition box",
		},
		command = [[prop]],
	},
	nb = {
		context = {
			name = "note",
			dscr = "add note box",
		},
		command = [[note]],
	},
	rmb = {
		context = {
			name = "remark",
			dscr = "add remark box",
		},
		command = [[rmk]],
	},
}

local tcolorbox_snippets = {}
for k, v in pairs(tcolorbox_specs) do
	table.insert(
		tcolorbox_snippets,
		tcolorbox_snippet(vim.tbl_deep_extend("keep", { trig = k }, v.context), v.command, { condition = tex.in_text })
	)
end
vim.list_extend(M, tcolorbox_snippets)

--{
-- Math Mode Snippets
--}

-- Auto backslashes
local auto_backslash_snippet = require("snippets.tex.utils").scaffolding.auto_backslash_snippet

local auto_backslash_specs = {
	"arcsin",
	"sin",
	"arccos",
	"cos",
	"arctan",
	"tan",
	"cot",
	"csc",
	"sec",
	"log",
	"ln",
	"exp",
	"ast",
	"star",
	"perp",
	"sup",
	"inf",
	"det",
	"max",
	"min",
	"argmax",
	"argmin",
    "deg",
    "angle",
}

local auto_backslash_snippets = {}
for _, v in ipairs(auto_backslash_specs) do
    table.insert(auto_backslash_snippets, auto_backslash_snippet({ trig = v }, { condition = tex.in_math }))
end
vim.list_extend(M, auto_backslash_snippets)

-- Symbols/Commands
local symbol_snippet = require("snippets.tex.utils").scaffolding.symbol_snippet

local greek_specs = {
	alpha = { context = { name = "α" }, command = [[\alpha]] },
	beta = { context = { name = "β" }, command = [[\beta]] },
	gam = { context = { name = "γ" }, command = [[\gamma]] },
	Gam = { context = { name = "Γ" }, command = [[\Gamma]] },
	delta = { context = { name = "δ" }, command = [[\delta]] },
	DD = { context = { name = "Δ" }, command = [[\Delta]] },
	eps = { context = { name = "ε" , priority = 500 }, command = [[\epsilon]] },
    veps = { context = { name = "ε" }, command = [[\varepsilon]] },
    zeta = { context = { name = "ζ" }, command = [[\zeta]] },
	eta = { context = { name = "η" , priority = 500}, command = [[\eta]] },
	theta = { context = { name = "θ" }, command = [[\theta]] },
	Theta = { context = { name = "Θ" }, command = [[\Theta]] },
	iota = { context = { name = "ι" }, command = [[\iota]] },
	kappa = { context = { name = "κ" }, command = [[\kappa]] },
	lmbd = { context = { name = "λ" }, command = [[\lambda]] },
	Lmbd = { context = { name = "Λ" }, command = [[\Lambda]] },
	mu = { context = { name = "μ" }, command = [[\mu]] },
	nu = { context = { name = "ν" }, command = [[\nu]] },
    xi = { context = { name = "ξ" }, command = [[\xi]] },
	pi = { context = { name = "π" }, command = [[\pi]] },
	rho = { context = { name = "ρ" }, command = [[\rho]] },
	sig = { context = { name = "σ" }, command = [[\sigma]] },
	Sig = { context = { name = "Σ" }, command = [[\Sigma]] },
    tau = { context = { name = "τ" }, command = [[\tau]] },
	ups = { context = { name = "υ" }, command = [[\upsilon]] },
    phi = { context = { name = "φ" }, command = [[\phi]] },
    vphi = { context = { name = "φ" }, command = [[\varphi]] },
    chi = { context = { name = "χ" }, command = [[\chi]] },
	psi = { context = { name = "Ψ" }, command = [[\psi]] },
	omega = { context = { name = "ω" }, command = [[\omega]] },
	Omega = { context = { name = "Ω" }, command = [[\Omega]] },
}

local greek_snippets = {}
for k, v in pairs(greek_specs) do
	table.insert(
		greek_snippets,
		symbol_snippet(vim.tbl_deep_extend("keep", { trig = k }, v.context), v.command, { condition = tex.in_math, backslash = true })
	)
end
vim.list_extend(M, greek_snippets)

local symbol_specs = {
	-- operators
	["!="] = { context = { name = "!=" }, command = [[\neq]] },
	["<="] = { context = { name = "≤" }, command = [[\leq]] },
	[">="] = { context = { name = "≥" }, command = [[\geq]] },
	["<<"] = { context = { name = "<<" }, command = [[\ll]] },
	[">>"] = { context = { name = ">>" }, command = [[\gg]] },
	["~~"] = { context = { name = "~" }, command = [[\sim]] },
	["~="] = { context = { name = "≈" }, command = [[\approx]] },
	["~-"] = { context = { name = "≃" }, command = [[\simeq]] },
	["-~"] = { context = { name = "⋍" }, command = [[\backsimeq]] },
	["-="] = { context = { name = "≡" }, command = [[\equiv]] },
	["=~"] = { context = { name = "≅" }, command = [[\cong]] },
	[":="] = { context = { name = "≔" }, command = [[\definedas]] },
	["**"] = { context = { name = "·", priority = 100 }, command = [[\cdot]] },
	xx = { context = { name = "×" }, command = [[\times]] },
	["!+"] = { context = { name = "⊕" }, command = [[\oplus]] },
	["!*"] = { context = { name = "⊗" }, command = [[\otimes]] },
	-- sets
	NN = { context = { name = "ℕ" }, command = [[\mathbb{N}]] },
	ZZ = { context = { name = "ℤ" }, command = [[\mathbb{Z}]] },
	QQ = { context = { name = "ℚ" }, command = [[\mathbb{Q}]] },
	RR = { context = { name = "ℝ" }, command = [[\mathbb{R}]] },
	CC = { context = { name = "ℂ" }, command = [[\mathbb{C}]] },
	OO = { context = { name = "∅" }, command = [[\emptyset]] },
	pwr = { context = { name = "P" }, command = [[\powerset]] },
	cc = { context = { name = "⊂" }, command = [[\subset]] },
	cq = { context = { name = "⊆" }, command = [[\subseteq]] },
	qq = { context = { name = "⊃" }, command = [[\supset]] },
	qc = { context = { name = "⊇" }, command = [[\supseteq]] },
	["\\\\\\"] = { context = { name = "⧵" }, command = [[\setminus]] },
	Nn = { context = { name = "∩" }, command = [[\cap]] },
	UU = { context = { name = "∪" }, command = [[\cup]] },
	["::"] = { context = { name = ":" }, command = [[\colon]] },
	-- quantifiers and logic stuffs
	AA = { context = { name = "∀" }, command = [[\forall]] },
	EE = { context = { name = "∃" }, command = [[\exists]] },
	inn = { context = { name = "∈" }, command = [[\in]] },
	notin = { context = { name = "∉" }, command = [[\not\in]] },
	["!-"] = { context = { name = "¬" }, command = [[\lnot]] },
	VV = { context = { name = "∨" }, command = [[\lor]] },
	WW = { context = { name = "∧" }, command = [[\land]] },
    ["!!"] = { context = {name = "neg"}, command = [[\neg]] },
    ["!W"] = { context = { name = "∧" }, command = [[\bigwedge]] },
	["=>"] = { context = { name = "⇒" }, command = [[\implies]] },
	["=<"] = { context = { name = "⇐" }, command = [[\impliedby]] },
	iff = { context = { name = "⟺" }, command = [[\iff]] },
	["->"] = { context = { name = "→", priority = 250 }, command = [[\to]] },
	["!>"] = { context = { name = "→" }, command = [[\mapsto]] },
	["<-"] = { context = { name = "←", priority = 250}, command = [[\gets]] },
    -- differentials 
	-- dd = { context = { name = "⇒" }, command = [[\dl]] },
	dp = { context = { name = "∂" }, command = [[\partial]] },
	-- arrows
	["-->"] = { context = { name = "⟶", priority = 500 }, command = [[\longrightarrow]] },
	["<->"] = { context = { name = "↔", priority = 500 }, command = [[\leftrightarrow]] },
	["2>"] = { context = { name = "⇉", priority = 400 }, command = [[\rightrightarrows]] },
	upar = { context = { name = "↑" }, command = [[\uparrow]] },
	dnar = { context = { name = "↓" }, command = [[\downarrow]] },
	-- etc
	ooo = { context = { name = "∞" }, command = [[\infty]] },
	lll = { context = { name = "ℓ" }, command = [[\ell]] },
	dag = { context = { name = "†" }, command = [[\dagger]] },
	["+-"] = { context = { name = "±" }, command = [[\pm]] },
	["-+"] = { context = { name = "∓" }, command = [[\mp]] },
}

local symbol_snippets = {}
for k, v in pairs(symbol_specs) do
	table.insert(
		symbol_snippets,
		symbol_snippet(vim.tbl_deep_extend("keep", { trig = k }, v.context), v.command, { condition = tex.in_math })
	)
end
vim.list_extend(M, symbol_snippets)

local single_command_math_specs = {
	tt = {
		context = {
			name = "text (math)",
			dscr = "text in math mode",
		},
		command = [[\text]],
	},
	sbf = {
		context = {
			name = "symbf",
			dscr = "bold math text",
		},
		command = [[\symbf]],
	},
	syi = {
		context = {
			name = "symit",
			dscr = "italic math text",
		},
		command = [[\symit]],
	},
	udd = {
		context = {
			name = "underline (math)",
			dscr = "underlined text in math mode",
		},
		command = [[\underline]],
	},
	floor = {
		context = {
			name = "floor",
			dscr = "math floor",
		},
		command = [[\floor]],
	},
	ceil = {
		context = {
			name = "ceil",
			dscr = "math ceiling",
		},
		command = [[\ceil]],
	},
	conj = {
		context = {
			name = "conjugate",
			dscr = "conjugate (overline)",
		},
		command = [[\overline]],
	},
	abs = {
		context = {
			name = "abs",
			dscr = "absolute value",
		},
		command = [[\abs]],
	},
	["__"] = {
		context = {
			name = "subscript",
			dscr = "auto subscript 3",
			wordTrig = false,
		},
		command = [[_]],
	},
	td = {
		context = {
			name = "superscript",
			dscr = "auto superscript alt",
			wordTrig = false,
		},
		command = [[^]],
	},
	sbt = {
		context = {
			name = "substack",
			dscr = "substack for sums/products",
		},
		command = [[\substack]],
	},
	sq = {
		context = {
			name = "sqrt",
			dscr = "sqrt",
		},
		command = [[\sqrt]],
		ext = { choice = true },
	},
	elr = {
		context = {
			name = "eval",
			dscr = "evaluate bar for integrals",
		},
		command = [[\eval]],
	},
	norm = {
		context = {
			name = "norm",
			dscr = "norm",
		},
		command = [[\norm]],
	},
	iprod = {
		context = {
			name = "vinner",
			dscr = "inner product",
		},
		command = [[\vinner]],
	},
}

local single_command_math_snippets = {}
for k, v in pairs(single_command_math_specs) do
	table.insert(
		single_command_math_snippets,
		single_command_snippet(
			vim.tbl_deep_extend("keep", { trig = k, snippetType = "autosnippet" }, v.context),
			v.command,
			v.opts or { condition = tex.in_math },
			v.ext or {}
		)
	)
end
vim.list_extend(M, single_command_math_snippets)

-- postfixes
local postfix_snippet = require("snippets.tex.utils").scaffolding.postfix_snippet

local postfix_specs = {
    vc = {
        context = {
            name = "mintinline",
            dscr = "mintinline",
        },
        command = {
            pre = [[\mintinline{text}{]],
            post = [[}]],
        }
    }
}

local postfix_snippets = {}
for k, v in pairs(postfix_specs) do
table.insert(
    postfix_snippets,
    postfix_snippet(
        vim.tbl_deep_extend("keep", { trig = k, snippetType = "autosnippet" }, v.context),
        v.command,
        { condition = tex.in_text }
    )
)
end
vim.list_extend(M, postfix_snippets)

local postfix_math_specs = {
    [',.'] = {
        context = {
            name = "vec",
            dscr = "vector"
        },
        command = {
            pre = [[\vec{]],
            post = [[}]]
        },
    },
    [',,.'] = {
        context = {
            name = "mat",
            dscr = "matrix"
        },
        command = {
            pre = [[\mat{]],
            post = [[}]]
        },
    },
    mbb = {
        context = {
            name = "mathbb",
            dscr =  "math blackboard bold",
        },
        command = {
            pre = [[\mathbb{]],
            post = [[}]],
        }
    },
    mcal = {
        context = {
            name = "mathcal",
            dscr =  "math calligraphic",
        },
        command = {
            pre = [[\mathcal{]],
            post = [[}]],
        }
    },
    mscr = {
        context = {
            name = "mathscr",
            dscr =  "math script",
        },
        command = {
            pre = [[\mathscr{]],
            post = [[}]],
        },
    },
    mfr = {
        context = {
            name = "mathfrak",
            dscr =  "mathfrak",
        },
        command = {
            pre = [[\mathfrak{]],
            post = [[}]],
        },
    },
    hat = {
		context = {
			name = "hat",
			dscr = "hat",
		},
		command = {
            pre = [[\hat{]],
            post = [[}]],
        }
	},
	bar = {
		context = {
			name = "bar",
			dscr = "bar (overline)",
		},
		command = {
            pre = [[\overline{]],
            post = [[}]]
        }
	},
    xbr = {
        context = {
            name = "bar",
            dscr = "bar (xoverline)",
        },
		command = {
            pre = [[\xoverline{]],
            post = [[}]]
        }
    },
	tld = {
		context = {
			name = "tilde",
            priority = 500,
			dscr = "tilde",
		},
		command = {
            pre = [[\tilde{]],
            post = [[}]]
        }
	},
	xtld = {
		context = {
			name = "xtilde",
			dscr = "tilde (wide)",
		},
		command = {
            pre = [[\xtilde{]],
            post = [[}]]
        }
	},
    ucat = {
        context = {
            name = "ucat",
            dscr = "ucat"
        },
		command = {
            pre = [[\ucat{]],
            post = [[}]]
        }
    },
}

local postfix_math_snippets = {}
for k, v in pairs(postfix_math_specs) do
table.insert(
    postfix_math_snippets,
    postfix_snippet(
        vim.tbl_deep_extend("keep", { trig = k, snippetType = "autosnippet" }, v.context),
        v.command,
        { condition = tex.in_math }
    )
)
end
vim.list_extend(M, postfix_math_snippets)

return M
