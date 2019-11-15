defmodule Mix.Tasks.Eunit do
  use Mix.Task

  # The main task should NOT be recursive; we want to explicitly enumerate
  # child projects, rather than allowing mix to do it.
  # Specifically, if we attempt to run "mix compile" in a child project,
  # mix compiles everything, _before_ we have a chance to modify the
  # compiler options
  @recursive false
  @preferred_cli_env :test

  @impl true
  def run(_args) do
    # We need to load dependencies first.
    Mix.Task.run("loadpaths")

    # Iterate over child projects.
    for {app, path} <- Mix.Project.apps_paths || [] do
      post_config = [
        erlc_paths: ["src", "test"],
        erlc_options: [{:d, :TEST}, {:debug_info}]
      ]
      Mix.Project.in_project(app, path, post_config, fn _ ->
        Mix.Task.run("compile")
      end)
    end

    Mix.Task.run("eunit.test")
  end
end
