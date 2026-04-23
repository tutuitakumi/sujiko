# frozen_string_literal: true

require "erb"
require "rbconfig"
require "socket"

module Sujiko
  class Server
    DEFAULT_PORT = 4567
    MAX_REQUEST_HEADER_SIZE = 16_384
    TEMPLATE = File.expand_path("templates/index.html.erb", __dir__)

    def self.start(port: DEFAULT_PORT, out: $stdout, err: $stderr)
      port = DEFAULT_PORT if port.nil?
      new(port, out, err).start
    end

    def start
      port = resolve_port
      html = render_template(port: port)
      base_url = "http://127.0.0.1:#{port}"
      body_utf8 = html.encode(Encoding::UTF_8)

      server = nil
      server = TCPServer.new("127.0.0.1", port)
      trap("INT") { server&.close }
      @out.puts "Sujiko: #{base_url} (Ctrl-C で停止)"
      try_open_browser(base_url, @err)

      loop do
        socket = server.accept
        begin
          handle_socket(socket, body_utf8)
        ensure
          socket.close
        end
      end
    rescue Errno::EBADF, Errno::EINVAL, IOError
      # 終了: `accept` 中にソケットを閉じたあと
    ensure
      server&.close
    end

    private

    def initialize(port, out, err)
      @port_argument = port
      @out = out
      @err = err
    end

    def render_template(port:)
      body = File.read(TEMPLATE, encoding: "UTF-8")
      ERB.new(body).result_with_hash(title: "Sujiko", port: port)
    end

    def resolve_port
      p = @port_argument
      return DEFAULT_PORT if p.nil?

      s = p.to_s
      return DEFAULT_PORT if s.empty?

      n = Integer(s, 10)
      n.positive? ? n : DEFAULT_PORT
    rescue ArgumentError, TypeError
      DEFAULT_PORT
    end

    def try_open_browser(url, err)
      return if ENV["SUJIKO_NO_BROWSER"]

      if RbConfig::CONFIG["host_os"] =~ /darwin|mac os/
        system("open", url)
      elsif RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin|bccwin|wince/
        system("start", "", url)
      else
        system("xdg-open", url) # XDG on Linux/Unix
      end
    rescue StandardError => e
      err.puts "ブラウザを開けませんでした: #{e.message}"
    end

    def handle_socket(socket, body_utf8)
      first_line = read_request_line(socket)
      if first_line.nil? || first_line !~ %r{^[A-Z]+\s}
        write_text_response(socket, 400, "Bad Request", "")
        return
      end

      method = first_line.split(/\s+/, 2).first
      case method
      when "GET"
        write_html_response(socket, body_utf8, head_only: false)
      when "HEAD"
        write_html_response(socket, body_utf8, head_only: true)
      else
        write_text_response(socket, 405, "Method Not Allowed", "")
      end
    end

    def read_request_line(socket)
      buf = +""
      until request_headers_complete?(buf)
        if buf.bytesize > MAX_REQUEST_HEADER_SIZE
          return
        end

        data = socket.readpartial(8_192)
        return if data.nil? || data.empty?

        buf << data
      end
      buf.split("\r\n", 2).first
    rescue EOFError, Errno::ECONNRESET, Errno::EPIPE, IOError
      nil
    end

    def request_headers_complete?(buf)
      buf.end_with?("\r\n\r\n") || buf.match?(%r{\r\n\r\n|\n\n})
    end

    def write_html_response(socket, body_utf8, head_only:)
      payload = head_only ? +"" : body_utf8
      header = "HTTP/1.1 200 OK\r\n" \
        "Content-Type: text/html; charset=utf-8\r\n" \
        "Content-Length: #{body_utf8.bytesize}\r\n" \
        "Connection: close\r\n" \
        "\r\n"
      socket.write(header.b)
      socket.write(payload.b) unless payload.empty?
    end

    def write_text_response(socket, status, message, _body = "")
      text = "HTTP/1.1 #{status} #{message}\r\n" \
        "Content-Length: 0\r\n" \
        "Connection: close\r\n" \
        "\r\n"
      socket.write(text.b)
    end

    private_class_method :new
  end
end
