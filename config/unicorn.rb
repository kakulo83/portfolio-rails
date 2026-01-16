parent_dir = File.expand_path("..", __dir__)
working_directory = parent_dir

stderr_path "#{working_directory}/log/unicorn.stderr.log"
stdout_path "#{working_directory}/log/unicorn.stdout.log"

worker_processes 4
listen "127.0.0.1:3000"
