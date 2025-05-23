-- luasnip configured with the custom tex snippets 
-- don't mess with this for now!!
return {
	"L3MON4D3/LuaSnip",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		ls = require("luasnip")
		ls.setup({
			region_check_events = "InsertEnter",
		})
		ls.config.set_config({
			history = true, -- keep around last snippet local to jump back
			enable_autosnippets = true,
			store_selection_keys = "<Tab>",
		})
		-- require("luasnip.loaders.from_snipmate").load({ paths = "~/.config/nvim/snippets/" })
		-- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
		require("luasnip.loaders.from_lua").load({
			paths = { "~/.config/nvim/lua/snippets/", "~/.config/nvim/lua/localsnippets/" },
			fs_event_providers = { libuv = true },
		})
		require("luasnip").filetype_extend("tex", { "cpp", "python" })
		vim.cmd([[silent command! LuaSnipEdit :lua require("luasnip.loaders").edit_snippet_files()]])
		-- external update dynamicNode
		local function find_dynamic_node(node)
			-- the dynamicNode-key is set on snippets generated by a dynamicNode only (its'
			-- actual use is to refer to the dynamicNode that generated the snippet).
			while not node.dynamicNode do
				node = node.parent
			end
			return node.dynamicNode
		end

		local external_update_id = 0
		-- func_indx to update the dynamicNode with different functions.
		function dynamic_node_external_update(func_indx)
			-- most of this function is about restoring the cursor to the correct
			-- position+mode, the important part are the few lines from
			-- `dynamic_node.snip:store()`.

			-- find current node and the innermost dynamicNode it is inside.
			local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
			local dynamic_node = find_dynamic_node(current_node)

			-- to identify current node in new snippet, if it is available.
			external_update_id = external_update_id + 1
			current_node.external_update_id = external_update_id

			-- store which mode we're in to restore later.
			local insert_pre_call = vim.fn.mode() == "i"
			-- is byte-indexed! Doesn't matter here, but important to be aware of.
			local cursor_pos_pre_relative = require("luasnip.util.util").pos_sub(
				require("luasnip.util.util").get_cursor_0ind(),
				current_node.mark:pos_begin_raw()
			)

			-- leave current generated snippet.
			require("luasnip.nodes.util").leave_nodes_between(dynamic_node.snip, current_node)

			-- call update-function.
			local func = dynamic_node.user_args[func_indx]
			if func then
				-- the same snippet passed to the dynamicNode-function. Any output from func
				-- should be stored in it under some unused key.
				func(dynamic_node.parent.snippet)
			end

			-- last_args is used to store the last args that were used to generate the
			-- snippet. If this function is called, these will most probably not have
			-- changed, so they are set to nil, which will force an update.
			dynamic_node.last_args = nil
			dynamic_node:update()

			-- everything below here isn't strictly necessary, but it's pretty nice to have.

			-- try to find the node we marked earlier.
			local target_node = dynamic_node:find_node(function(test_node)
				return test_node.external_update_id == external_update_id
			end)

			if target_node then
				-- the node that the cursor was in when changeChoice was called exists
				-- in the active choice! Enter it and all nodes between it and this choiceNode,
				-- then set the cursor.
				require("luasnip.nodes.util").enter_nodes_between(dynamic_node, target_node)

				if insert_pre_call then
					require("luasnip.util.util").set_cursor_0ind(
						require("luasnip.util.util").pos_add(target_node.mark:pos_begin_raw(), cursor_pos_pre_relative)
					)
				else
					require("luasnip.nodes.util").select_node(target_node)
				end
				-- set the new current node correctly.
				ls.session.current_nodes[vim.api.nvim_get_current_buf()] = target_node
			else
				-- the marked node wasn't found, just jump into the new snippet noremally.
				ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
			end
		end
	end,
}
