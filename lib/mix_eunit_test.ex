defmodule Mix.Tasks.Eunit.Test do
  use Mix.Task

  # The "mix eunit.test" task _should_ be recursive.
  @recursive true
  @preferred_cli_env :test

  @impl true
  def run(_args) do
    opts = [:verbose]

    # ".../top/_build/test/lib/app"
    app_path = Mix.Project.app_path()

    # Ensure that 'ebin' is in the code search path; if the app isn't mentioned
    # in a dependency, it doesn't get added by default.
    ebin_path = Path.join([app_path, "ebin"])
    Code.append_path(ebin_path)

    modules = get_test_modules(ebin_path)
    :eunit.test(modules, opts)
  end

  defp get_test_modules(ebin_path) do
    glob = Path.join([ebin_path, "*.beam"])

    Path.wildcard(glob)
    |> Enum.map(&(Path.basename(&1, ".beam")))
    |> remove_duplicates
    |> Enum.map(&String.to_atom/1)
  end

  defp remove_duplicates(modules) do
    # If 'module' has a corresponding 'modules_tests', remove the '_tests' variant.
    List.foldl(modules, modules, fn m, acc ->
      m_tests = m <> "_tests"

      if Enum.member?(acc, m_tests) do
        List.delete(acc, m_tests)
      else
        acc
      end
    end)
  end
end
