ps -ef | grep "examples/config" | awk '{print $2}' | xargs kill -9
