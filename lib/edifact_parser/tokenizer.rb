require_relative 'format'
require 'strscan'

module EdifactParser
  class Tokenizer
    def initialize(io)
      source = io.read
      @format = Format.from_source(source)
      @ss = StringScanner.new source
    end

    def next_token
      return if end_of_string_reached?

      # ignore spaces and line breaks
      scan(:space) and scan(:line_break)

      return if end_of_string_reached?

      case
      when text = scan(:optional_begin) then [:OPTIONAL_BEGIN, text]
      when text = scan(:qualifiers) then [:QUALIFIER, text]
      when text = scan(:segment_end) then [:SEGMENT_END, text]
      when text = scan(:plus) then [:PLUS, text]
      when text = scan(:colon) then [:COLON, text]
      when text = scan(:number) then [:NUMBER, text]
      when text = scan(:string) then [:STRING, text]
      else
        x = @ss.getch
        [x, x]
      end
    end

    private

    def number(text)
      begin
        Integer(text)
      rescue
        text.gsub(/\D/, '.').to_f
      end
    end

    def scan(name)
      @ss.scan(@format.get(name))
    end

    def match(name, text)
      @format.get(name).match(text)
    end

    def end_of_string_reached?
      @ss.eos?
    end
  end
end
