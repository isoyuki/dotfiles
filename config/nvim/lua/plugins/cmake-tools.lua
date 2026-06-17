return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "CMakeGenerate",
      "CMakeBuild",
      "CMakeRun",
      "CMakeRunTest",
      "CMakeOpenCache",
      "CMakeSelectBuildType",
      "CMakeSelectBuildTarget",
      "CMakeSelectLaunchTarget",
    },
    keys = {
      { "<leader>cg", "<cmd>CMakeGenerate<CR>", desc = "CMake: Generate (configure)" },
      { "<leader>cb", "<cmd>CMakeBuild<CR>", desc = "CMake: Build" },
      { "<leader>cr", "<cmd>CMakeRun<CR>", desc = "CMake: Run target" },
      { "<leader>ct", "<cmd>CMakeSelectBuildType<CR>", desc = "CMake: Select build type" },
      { "<leader>ce", "<cmd>CMakeOpenCache<CR>", desc = "CMake: Open cache" },
    },
    opts = {
      cmake_build_directory = "out/${variant:buildType}",
      cmake_soft_link_compile_commands = true, -- symlink compile_commands.json for clangd
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
    },
  },
}
