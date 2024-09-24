import subprocess

result = subprocess.run(["ls -la"], shell=True, timeout=10, capture_output=True)
print(result.stdout.decode("utf-8"))
