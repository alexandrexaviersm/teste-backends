Code.require_file("./solution.ex")

input_files = [
  "./../test/input/input000.txt",
  "./../test/input/input001.txt",
  "./../test/input/input002.txt",
  "./../test/input/input003.txt",
  "./../test/input/input004.txt",
  "./../test/input/input005.txt",
  "./../test/input/input006.txt",
  "./../test/input/input007.txt",
  "./../test/input/input008.txt",
  "./../test/input/input009.txt",
  "./../test/input/input010.txt",
  "./../test/input/input011.txt",
  "./../test/input/input012.txt"
]

output_files = [
  "./../test/output/output000.txt",
  "./../test/output/output001.txt",
  "./../test/output/output002.txt",
  "./../test/output/output003.txt",
  "./../test/output/output004.txt",
  "./../test/output/output005.txt",
  "./../test/output/output006.txt",
  "./../test/output/output007.txt",
  "./../test/output/output008.txt",
  "./../test/output/output009.txt",
  "./../test/output/output010.txt",
  "./../test/output/output011.txt",
  "./../test/output/output012.txt"
]

for {input_file, index} <- Enum.with_index(input_files) do
  input_lines =
    File.read!(input_file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)

  output_lines =
    Enum.at(output_files, index)
    |> File.read!()
    |> String.trim()

  if Solution.process_messages(input_lines) == output_lines do
    IO.puts("Test #{index + 1}/#{length(input_files)} - Passed")
  else
    IO.puts("Test #{index + 1}/#{length(input_files)} - Failed")
  end
end
