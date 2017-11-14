require "data_anonymizer/version"
require 'singleton'

class  DataAnonymizer 
  include Singleton

  @@models_to_anonymize = nil
  @@attributes_to_sync = nil

  NUMBERS = ('0'..'9').to_a
  ALPHABETS = ("a".."z").to_a

  #model_names = ["Person", "CensusMember", "CuramUser"]
  #sync_attributes = ["first_name", "last_name", "ssn"]

  def anonymize_common_attributes(model_names, sync_attributes)
    return if model_names.blank? || sync_attributes.blank?

    @@models_to_anonymize = process_model_names(model_names)
    @@attributes_to_sync = process_sync_attributes(sync_attributes)
    
    puts 'Data Anonymization Started...'
    puts '*' * 85
    # Update attributes that need to be in sync accross Models.
    @@attributes_to_sync.each do  |attribute|
      puts "Anonymizing attribute: #{attribute} across #{@@models_to_anonymize}"
      cipher_hash = build_substitution_cipher_hash_for(attribute)
      @@models_to_anonymize.each do |model|
        puts "   - Processing #{model} Model"
        model.constantize.each do |instance|
          updated = false
          while !updated do
            begin
              instance.update_attributes(attribute => encrypt_characters(cipher_hash, instance.send(attribute))) if instance.send(attribute).present?
              updated = true
            rescue Exception => e
              puts "Error updating [#{attribute}] for [#{instance.class}, ID: #{instance.id}]. Retrying with a new shuffled value.. (Error Message: #{e.message})"
            end
          end
        end
      end
    end
    puts '*' * 85
    puts 'Data Anonymization Complete!!!'
  end

  private

  def process_model_names(model_names)
    model_names.map { |m| m.to_s }
  end

  def process_sync_attributes(sync_attributes)
    sync_attributes
  end

  def build_substitution_cipher_hash_for(attribute)
    if attribute.to_sym == :ssn
      loop do
        # Keep Shuffling until SSN is unique
        shuffled_chars = NUMBERS.shuffle
        return NUMBERS.zip(shuffled_chars).to_h if no_ssn_collision?(shuffled_chars)  
      end
    else
      shuffled_chars = ALPHABETS.shuffle
      ALPHABETS.zip(shuffled_chars).to_h
    end
  end

  def encrypt_characters(cipher_hash, attribute_value)
    encrypted_value = ""
    attribute_value.gsub!(/[^0-9A-Za-z]/, '') # remove non-alphanumeric characters from string.
    attribute_value.downcase.split('').each {|char| encrypted_value << cipher_hash[char]}
    encrypted_value
  end

  def no_ssn_collision?(shuffled_chars)
    @@models_to_anonymize.each do  |model|
      return false if model.constantize.where(ssn: shuffled_chars).present?
    end
    return true
  end
end
