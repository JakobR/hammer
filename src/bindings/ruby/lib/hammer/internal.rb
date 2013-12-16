require 'ffi'

module Hammer
  module Internal
    extend FFI::Library

    ffi_lib 'libhammer.dylib'

    # Maybe we can implement Hammer::Parser with FFI::DataConverter.
    # That way, most hammer functions won't need to be wrapped.
    # (Probably need to wrap token, sequence and choice only).
    # See http://www.elabs.se/blog/61-advanced-topics-in-ruby-ffi
    typedef :pointer, :h_parser

    HTokenType = enum(:none, 1,
                      :bytes, 2,
                      :sint, 4,
                      :uint, 8,
                      :sequence, 16,
                      :reserved_1,
                      :err, 32,
                      :user, 64,
                      :max)

    class HCountedArray < FFI::Struct
      layout  :capacity, :size_t,
              :used, :size_t,
              :arena, :pointer,
              :elements, :pointer # HParsedToken**

      def elements
        elem_array = FFI::Pointer.new(:pointer, self[:elements])
        return (0...self[:used]).map { |i| HParsedToken.new(elem_array[i].read_pointer) }
      end
    end

    class HBytes < FFI::Struct
      layout  :token, :pointer, # uint8_t*
              :len, :size_t
    end

    class HParsedTokenDataUnion < FFI::Union
      layout  :bytes, HBytes.by_value,
              :sint, :int64,
              :uint, :uint64,
              :dbl, :double,
              :flt, :float,
              :seq, HCountedArray.by_ref,
              :user, :pointer
    end

    class HParsedToken < FFI::Struct
      layout  :token_type, HTokenType,
              :data, HParsedTokenDataUnion.by_value,
              :index, :size_t,
              :bit_offset, :char
    end

    class HParseResult < FFI::Struct
      layout  :ast, HParsedToken.by_ref,
              :bit_length, :long_long,
              :arena, :pointer

      def self.release(ptr)
        Hammer::Internal.h_parse_result_free(ptr) unless ptr.null?
      end
    end

    # run a parser
    attach_function :h_parse, [:h_parser, :string, :size_t], HParseResult.auto_ptr # TODO: Use :buffer_in instead of :string?

    # build a parser
    attach_function :h_token, [:buffer_in, :size_t], :h_parser
    attach_function :h_ch, [:uint8], :h_parser
    attach_function :h_ch_range, [:uint8, :uint8], :h_parser
    attach_function :h_int_range, [:int64, :int64], :h_parser
    attach_function :h_bits, [:size_t, :bool], :h_parser
    attach_function :h_int64, [], :h_parser
    attach_function :h_int32, [], :h_parser
    attach_function :h_int16, [], :h_parser
    attach_function :h_int8,  [], :h_parser
    attach_function :h_uint64, [], :h_parser
    attach_function :h_uint32, [], :h_parser
    attach_function :h_uint16, [], :h_parser
    attach_function :h_uint8,  [], :h_parser
    attach_function :h_whitespace, [:h_parser], :h_parser
    attach_function :h_left,   [:h_parser, :h_parser], :h_parser
    attach_function :h_right,  [:h_parser, :h_parser], :h_parser
    attach_function :h_middle, [:h_parser, :h_parser, :h_parser], :h_parser
    #attach_function :h_in, [:buffer_in, :size_t], :h_parser
    #attach_function :h_not_in, [:buffer_in, :size_t], :h_parser
    attach_function :h_end_p, [], :h_parser
    attach_function :h_nothing_p, [], :h_parser
    attach_function :h_sequence, [:varargs], :h_parser
    attach_function :h_choice, [:varargs], :h_parser
    attach_function :h_butnot, [:h_parser, :h_parser], :h_parser
    attach_function :h_difference, [:h_parser, :h_parser], :h_parser
    attach_function :h_xor, [:h_parser, :h_parser], :h_parser
    attach_function :h_many, [:h_parser], :h_parser
    attach_function :h_many1, [:h_parser], :h_parser
    #attach_function :h_repeat_n, [:h_parser, :size_t], :h_parser
    attach_function :h_optional, [:h_parser], :h_parser
    attach_function :h_ignore, [:h_parser], :h_parser
    attach_function :h_sepBy, [:h_parser, :h_parser], :h_parser
    attach_function :h_sepBy1, [:h_parser, :h_parser], :h_parser
    attach_function :h_epsilon_p, [], :h_parser
    attach_function :h_length_value, [:h_parser, :h_parser], :h_parser
    attach_function :h_and, [:h_parser], :h_parser
    attach_function :h_not, [:h_parser], :h_parser

    attach_function :h_indirect, [], :h_parser
    attach_function :h_bind_indirect, [:h_parser, :h_parser], :void

    #attach_function :h_action, [:h_parser, ...], :h_parser
    #attach_function :h_attr_bool, [:h_parser, ...], :h_parser

    # free the parse result
    attach_function :h_parse_result_free, [HParseResult.by_ref], :void

    # TODO: Does the HParser* need to be freed?
  end
end
