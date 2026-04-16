# Split a name into parts to construct a pattern suitable for a Regexp
# CensorRule#text
class User::Anonymisable::NamePattern
  DEFAULT_HONORIFICS = 'Mr|Mrs|Miss|Ms|Mx'
  DEFAULT_PATTERN = '\b(?:(?:%{honorifics})\.?\s+(?:%{firstname}\s+)?%{surname}|%{firstname}(?:\s+%{surname}|\s+%{last_initial}\.?)?|%{first_initial}\.?\s*%{surname}|%{surname},\s+(?:%{firstname}|%{first_initial}\.?))(?!\w)'

  cattr_accessor :honorifics, default: DEFAULT_HONORIFICS
  cattr_accessor :pattern, default: DEFAULT_PATTERN

  def initialize(name)
    @name = name
  end

  def to_censor_rule_text
    format(pattern, substitutions)
  end

  # Hash with Regexp-escaped values
  # honorifics is a Regexp fragment so left unescaped
  def substitutions
    to_h.
      except(:honorifics).
      transform_values { |v| Regexp.escape(v) }.
      merge(honorifics: honorifics)
  end

  def to_h
    { firstname: firstname, surname: surname,
      first_initial: first_initial, last_initial: last_initial,
      honorifics: honorifics }
  end

  def firstname
    parts.first
  end

  def surname
    parts.last
  end

  def first_initial
    parts.first.mb_chars.first.to_s
  end

  def last_initial
    parts.last.mb_chars.first.to_s
  end

  protected

  attr_reader :name

  private

  def parts
    @parts ||= @name.strip.split(/\s+/)
  end
end
