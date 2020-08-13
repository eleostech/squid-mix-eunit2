defmodule Mix.Tasks.Eunit do
  use Mix.Task

  @shortdoc "Run eunit tests"

  @moduledoc """
  Runs the eunit tests for a project.

  Usage:

      MIX_ENV=test mix do compile, eunit

  This task assumes that MIX_ENV=test causes your Erlang project to define
  the `TEST` macro, and to add "test" to the `erlc_paths` option.

  ## Command line options

    * `--verbose` - enables verbose output
    * `--surefire` - enables Surefire-compatible XML output
    * `--cover` - exports coverage data (as `eunit.coverdata`)

  ## Coverage

  To get coverage data, run with the `--cover` switch:

      MIX_ENV=test mix do compile, eunit --cover
  """

  @recursive true
  @preferred_cli_env :test

  def run, do: run([])

  @impl true
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args, strict: [verbose: :boolean, surefire: :boolean, cover: :boolean])

    Mix.shell().print_app()
    project = Mix.Project.config()

    Mix.Task.run("loadpaths")

    # ".../top/_build/test/lib/app"
    app_path = Mix.Project.app_path()
    ebin_path = Path.join([app_path, "ebin"])

    # Ensure that 'ebin' is in the code search path; if the app isn't mentioned
    # in a dependency, it doesn't get added by default.
    Code.append_path(ebin_path)

    modules = get_test_modules(ebin_path)
    eunit_opts = convert_opts(opts)

    if opts[:cover] do
      _ = :cover.stop()
      {:ok, _pid} = :cover.start()

      compile_path = Mix.Project.compile_path(project)
      case :cover.compile_beam_directory(to_charlist(compile_path)) do
        results when is_list(results) ->
          :ok

        {:error, reason} ->
          Mix.raise(
            "Failed to cover compile directory #{inspect(Path.relative_to_cwd(compile_path))} " <>
              "with reason: #{inspect(reason)}"
          )
      end
    end

    case :eunit.test(modules, eunit_opts) do
      :ok -> :ok
      :error -> Mix.raise("One or more tests failed.")
    end

    if opts[:cover] do
      coverdata = Path.join([app_path, "eunit.coverdata"])
      case :cover.export(coverdata) do
        :ok ->
          Mix.shell().info(["Coverage data written to #{coverdata}"])
          :ok
        {:error, reason} ->
          Mix.raise(
            "Failed to export coverage data: #{inspect(reason)}"
          )
        end

      _ = :cover.stop()
    end
  end

  defp convert_opts(opts) do
    Enum.flat_map(opts, &convert_opt/1)
  end

  defp convert_opt({:verbose, true}), do: [:verbose]
  defp convert_opt({:surefire, true}), do: [{:report, {:eunit_surefire, [{:dir, "."}]}}]
  defp convert_opt(_), do: []

  defp get_test_modules(ebin_path) do
    glob = Path.join([ebin_path, "*.beam"])

    Path.wildcard(glob)
    |> Enum.map(&Path.basename(&1, ".beam"))
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
