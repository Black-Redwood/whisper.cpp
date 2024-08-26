import json
import subprocess
import signal
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

transcribe_process = None

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        global transcribe_process

        # Read and parse the incoming JSON data
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        request_body = json.loads(post_data)

        # Set the response header
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

        if 'url' in request_body:
            # Transcribe and summarize the video
            transcribe_process = subprocess.Popen(
                ['bash', 'transcribe.sh', request_body['url']],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            # Stream the output as it is generated
            for line in iter(transcribe_process.stdout.readline, b''):
                self.wfile.write(line)
                self.wfile.flush()
                print(line.decode('utf-8'), end='')

            transcribe_process.stdout.close()
            transcribe_process.wait()
            transcribe_process = None

        else:
            self.wfile.write(b'Invalid request received.')

def signal_handler(sig, frame):
    global transcribe_process
    print('Server is shutting down...')

    if transcribe_process is not None:
        print('Killing transcribe process...')
        transcribe_process.terminate()
        transcribe_process.wait()

    sys.exit(0)

def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=3456):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Server running on port {port}")

    # Register the signal handler for termination signals
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    httpd.serve_forever()

if __name__ == "__main__":
    run()
