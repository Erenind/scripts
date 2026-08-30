import time
import subprocess
while True:
    time.sleep(600);
    subprocess.run(["waypaper", "--random"])
    subprocess.run(["hyprctl", "reload"])
