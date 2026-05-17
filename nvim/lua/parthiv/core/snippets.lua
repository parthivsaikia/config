-- lua/parthiv/core/snippets.lua
local snippet = vim.snippet

local function add(trigger, body)
	return { trigger = trigger, body = body }
end

local snippets = {
	-- ──────────────────────────────────────────
	-- Global (all filetypes)
	-- ──────────────────────────────────────────
	all = {
		add("todo", "TODO: $1"),
		add("fixme", "FIXME: $1"),
		add("note", "NOTE: $1"),
		-- use functions so they're evaluated at expansion time, not load time
		{
			trigger = "date",
			body = function()
				return os.date("%Y-%m-%d")
			end,
		},
		{
			trigger = "time",
			body = function()
				return os.date("%H:%M:%S")
			end,
		},
		{
			trigger = "datetime",
			body = function()
				return os.date("%Y-%m-%d %H:%M:%S")
			end,
		},
	},

	-- ──────────────────────────────────────────
	-- Lua
	-- ──────────────────────────────────────────
	lua = {
		add("fn", "local function ${1:name}(${2:args})\n\t$3\nend"),
		add("lf", "local ${1:name} = function(${2:args})\n\t$3\nend"),
		add("req", 'local ${1:name} = require("${2:module}")'),
		add("if", "if ${1:cond} then\n\t$2\nend"),
		add("ife", "if ${1:cond} then\n\t$2\nelse\n\t$3\nend"),
		add("for", "for ${1:i} = ${2:1}, ${3:n} do\n\t$4\nend"),
		add("fori", "for ${1:i}, ${2:v} in ipairs(${3:tbl}) do\n\t$4\nend"),
		add("pf", 'print(string.format("${1:%s}", ${2:val}))'),
	},

	-- ──────────────────────────────────────────
	-- Go
	-- ──────────────────────────────────────────
	go = {
		-- Functions & methods
		add("fn", "func ${1:name}(${2:args}) ${3:returnType} {\n\t$4\n}"),
		add("meth", "func (${1:r} ${2:Receiver}) ${3:name}(${4:args}) ${5:returnType} {\n\t$6\n}"),
		add("main", 'package main\n\nimport "fmt"\n\nfunc main() {\n\t$1\n}'),

		-- Error handling (the Go way)
		add("iferr", 'if err != nil {\n\treturn ${1:nil, }fmt.Errorf("${2:context}: %w", err)\n}'),
		add("errf", 'fmt.Errorf("${1:message}: %w", ${2:err})'),
		add("errs", 'errors.New("${1:message}")'),

		-- Structs & interfaces
		add("st", "type ${1:Name} struct {\n\t${2:Field} ${3:Type}\n}"),
		add("iface", "type ${1:Name} interface {\n\t${2:Method}(${3:args}) ${4:returnType}\n}"),
		add("ctor", "func New${1:Name}(${2:args}) *${1:Name} {\n\treturn &${1:Name}{\n\t\t$3\n\t}\n}"),

		-- Concurrency
		add("goroutine", "go func() {\n\t$1\n}()"),
		add("chan", "${1:ch} := make(chan ${2:Type}, ${3:0})"),
		add("select", "select {\ncase ${1:v} := <-${2:ch}:\n\t$3\ndefault:\n\t$4\n}"),
		add("mutex", "var ${1:mu} sync.Mutex\n${1:mu}.Lock()\ndefer ${1:mu}.Unlock()"),

		-- Common patterns
		add(
			"test",
			'func Test${1:Name}(t *testing.T) {\n\t${2:got} := ${3:funcUnderTest}($4)\n\t${5:want} := ${6:expected}\n\tif ${2:got} != ${5:want} {\n\t\tt.Errorf("got %v, want %v", ${2:got}, ${5:want})\n\t}\n}'
		),
		add("bench", "func Benchmark${1:Name}(b *testing.B) {\n\tfor i := 0; i < b.N; i++ {\n\t\t$2\n\t}\n}"),
		add(
			"http",
			'http.HandleFunc("/${1:path}", func(w http.ResponseWriter, r *http.Request) {\n\t$2\n})\nhttp.ListenAndServe(":${3:8080}", nil)'
		),
		add("log", 'log.Printf("${1:message}", $2)'),
		add("init", "func init() {\n\t$1\n}"),
		add("defer", "defer ${1:func}()"),

		-- Imports
		add("imp", 'import (\n\t"${1:package}"\n)'),
	},

	-- ──────────────────────────────────────────
	-- Zig
	-- ──────────────────────────────────────────
	zig = {
		-- Basic structure
		add("main", 'const std = @import("std");\n\npub fn main() !void {\n\t$1\n}'),
		add("imp", 'const ${1:name} = @import("${2:module}");'),
		add("print", 'std.debug.print("${1:message}\\n", .{$2});'),

		-- Functions
		add("fn", "pub fn ${1:name}(${2:args}) ${3:returnType} {\n\t$4\n}"),
		add("fnp", "fn ${1:name}(${2:args}) ${3:returnType} {\n\t$4\n}"),

		-- Error handling
		add("try", "try ${1:expr};"),
		add("errset", "const ${1:MyError} = error{\n\t${2:SomeError},\n};"),
		add("catch", "${1:expr} catch |${2:err}| {\n\t$3\n}"),
		add("orelse", "${1:optional} orelse ${2:default}"),

		-- Structs & enums
		add(
			"st",
			"const ${1:Name} = struct {\n\t${2:field}: ${3:Type},\n\n\tpub fn init(${4:args}) ${1:Name} {\n\t\treturn .{ $5 };\n\t}\n};"
		),
		add("en", "const ${1:Name} = enum {\n\t${2:variant1},\n\t${3:variant2},\n};"),
		add("tagged", "const ${1:Name} = union(enum) {\n\t${2:variant}: ${3:Type},\n};"),

		-- Memory & allocators
		add(
			"alloc",
			"const ${1:allocator} = std.heap.GeneralPurposeAllocator(.{}){};\ndefer _ = ${1:allocator}.deinit();"
		),
		add("alist", "var ${1:list} = std.ArrayList(${2:Type}).init(${3:allocator});\ndefer ${1:list}.deinit();"),
		add("amap", "var ${1:map} = std.AutoHashMap(${2:K}, ${3:V}).init(${4:allocator});\ndefer ${1:map}.deinit();"),

		-- Control flow
		add("if", "if (${1:cond}) {\n\t$2\n}"),
		add("ife", "if (${1:cond}) {\n\t$2\n} else {\n\t$3\n}"),
		add("sw", "switch (${1:val}) {\n\t.${2:variant} => $3,\n\telse => $4,\n}"),
		add("while", "while (${1:cond}) {\n\t$2\n}"),
		add("for", "for (${1:slice}, 0..) |${2:item}, ${3:i}| {\n\t$4\n}"),

		-- Testing
		add("test", 'test "${1:description}" {\n\ttry std.testing.expect($2);\n}'),
		add("testeq", 'test "${1:description}" {\n\ttry std.testing.expectEqual(${2:expected}, ${3:actual});\n}'),

		-- Comptime
		add("ctime", "comptime {\n\t$1\n}"),
		add("ctif", "if (comptime ${1:cond}) {\n\t$2\n}"),
	},

	-- ──────────────────────────────────────────
	-- TypeScript
	-- ──────────────────────────────────────────
	typescript = {
		-- Functions
		add("fn", "function ${1:name}(${2:args}): ${3:void} {\n\t$4\n}"),
		add("af", "const ${1:name} = (${2:args}): ${3:void} => {\n\t$4\n}"),
		add("afr", "const ${1:name} = (${2:args}): ${3:ReturnType} => $4"),
		add("asyncfn", "async function ${1:name}(${2:args}): Promise<${3:void}> {\n\t$4\n}"),
		add("asyncaf", "const ${1:name} = async (${2:args}): Promise<${3:void}> => {\n\t$4\n}"),

		-- Types & interfaces
		add("int", "interface ${1:Name} {\n\t${2:prop}: ${3:Type};\n}"),
		add("typ", "type ${1:Name} = ${2:Type}"),
		add("gen", "type ${1:Name}<${2:T}> = ${3:Type}"),
		add("enum", 'enum ${1:Name} {\n\t${2:Member} = "${3:value}",\n}'),
		add("ce", "const enum ${1:Name} {\n\t${2:Member},\n}"),

		-- Classes
		add("cl", "class ${1:Name} {\n\tconstructor(${2:args}) {\n\t\t$3\n\t}\n}"),
		add("clext", "class ${1:Name} extends ${2:Base} {\n\tconstructor(${3:args}) {\n\t\tsuper($4);\n\t\t$5\n\t}\n}"),
		add("clprop", "private readonly ${1:prop}: ${2:Type};"),

		-- React (TSX friendly)
		add(
			"rfc",
			"import React from 'react';\n\ninterface ${1:Name}Props {\n\t$2\n}\n\nconst ${1:Name}: React.FC<${1:Name}Props> = ({ $3 }) => {\n\treturn (\n\t\t$4\n\t);\n};\n\nexport default ${1:Name};"
		),
		add("usestate", "const [${1:state}, set${1/(.)/\\u$1/}] = useState<${2:Type}>(${3:initialValue});"),
		add("useeff", "useEffect(() => {\n\t$1\n\treturn () => {\n\t\t$2\n\t};\n}, [${3:deps}]);"),

		-- Error handling
		add("tc", "try {\n\t$1\n} catch (error) {\n\tconst err = error as Error;\n\t$2\n}"),
		add(
			"trycatch",
			"try {\n\t${1:await $2}\n} catch (error) {\n\tif (error instanceof ${3:Error}) {\n\t\t$4\n\t}\n} finally {\n\t$5\n}"
		),

		-- Common patterns
		add("log", "console.log(${1:value})"),
		add("logjson", "console.log(JSON.stringify(${1:value}, null, 2))"),
		add("imp", 'import { ${1:name} } from "${2:module}"'),
		add("impd", 'import ${1:name} from "${2:module}"'),
		add("exp", "export const ${1:name} = ${2:value}"),
		add("expd", "export default ${1:value}"),
		add("tern", "${1:cond} ? ${2:then} : ${3:else}"),
		add("nullc", "${1:value} ?? ${2:default}"),
		add("optc", "${1:obj}?.${2:prop}"),

		-- Zod (very common in TS)
		add(
			"zobj",
			"const ${1:Schema} = z.object({\n\t${2:field}: z.${3:string}(),\n});\ntype ${1:Schema} = z.infer<typeof ${1:Schema}>;"
		),
	},

	-- ──────────────────────────────────────────
	-- Python
	-- ──────────────────────────────────────────
	python = {
		add("def", "def ${1:name}(${2:args}):\n\t${3:pass}"),
		add("cl", "class ${1:Name}:\n\tdef __init__(self${2:, args}):\n\t\t$3"),
		add("ifm", 'if __name__ == "__main__":\n\t$1'),
		add("imp", "import $1"),
		add("fimp", "from ${1:module} import ${2:name}"),
		add("tc", "try:\n\t$1\nexcept ${2:Exception} as e:\n\t$3"),
		add("log", 'print(f"${1:message}")'),
	},

	-- ──────────────────────────────────────────
	-- JavaScript
	-- ──────────────────────────────────────────
	javascript = {
		add("fn", "function ${1:name}(${2:args}) {\n\t$3\n}"),
		add("af", "const ${1:name} = (${2:args}) => {\n\t$3\n}"),
		add("cl", "class ${1:Name} {\n\tconstructor(${2:args}) {\n\t\t$3\n\t}\n}"),
		add("imp", 'import { ${1:name} } from "${2:module}"'),
		add("log", "console.log($1)"),
		add("tc", "try {\n\t$1\n} catch (${2:error}) {\n\t$3\n}"),
	},
}

local function setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("NativeSnippets", { clear = true }),
		callback = function(event)
			local ft = event.match
			local ft_snippets = snippets[ft] or {}
			local global_snippets = snippets.all or {}

			local all = vim.list_extend(vim.deepcopy(global_snippets), ft_snippets)

			-- Fix: assign the full list directly, don't try to append
			vim.b["snippets"] = all
		end,
	})

	-- Fix: also run for the current buffer immediately in case
	-- the FileType event already fired before setup() was called
	local ft = vim.bo.filetype
	if ft and ft ~= "" then
		local ft_snippets = snippets[ft] or {}
		local global_snippets = snippets.all or {}
		vim.b["snippets"] = vim.list_extend(vim.deepcopy(global_snippets), ft_snippets)
	end
end
return { setup = setup, snippets = snippets }
