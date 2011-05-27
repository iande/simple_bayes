# encoding: utf-8

# Author::    Zeke Templin
#             Ian D. Eccles
#             Lucas Carlson  (mailto:lucas@rufy.com)
# Copyright:: Copyright (c) 2005 Lucas Carlson
# License::   LGPL

module SimpleBayes  
  class Bayes
    include Categorical
    
    attr_reader :categories, :term_frequencies
    
    # The class can be created with one or more categories, each of which will be
    # initialized and given a training method. E.g., 
    #      b = SimpleBayes::Bayes.new :interesting, :uninteresting
    def initialize(*categories)
      @categories = {}
      @term_frequencies = Hash.new 0
      create_categories categories
    end

    #
    # Provides a general training method for all categories specified in Bayes#new
    # For example:
    #     b = SimpleBayes::Bayes.new :this, :that, :the_other
    #     b.train :this, "This text"
    #     b.train :that, "That text"
    #     b.train :the_other, "The other text"
    def train(name, text)
      doc = Document.new text
      store_terms doc
      category(name).train doc
    end

    #
    # Provides a untraining method for all categories specified in Bayes#new
    # Be very careful with this method.
    #
    # For example:
    #     b = SimpleBayes::Bayes.new :this, :that, :the_other
    #     b.train :this, "This text"
    #     b.untrain :this, "This text"
    def untrain(name, text)
      doc = Document.new text
      remove_terms doc
      category(name).untrain doc
    end
    
    # Probability that a given category should contain `text`:
    #
    #     P(A = category | B = text) = P(A | B1, B2, ... Bn)
    #
    # where Bi is a "word" or "term" extracted from B.
    # Assuming our Bi terms are independent ( P(Bi|Bj) = P(Bi) ), Bayes'
    # theorem tells us:
    #
    #     P(A | B1, ..., Bn) = ( P(A) * P(B1 | A) * ... * P(Bn | A) ) / ( P(B1) * ... * P(Bn) )
    # 
    # In our implementation, we'll use the application of a logarithm to
    # mitigate excessive multiplication rounding to 0.  If the term Bi has
    # not yet been encountered, we will assume a value of P(Bi) = 0.05.
    def classifications text, default_prob = 0.05
      doc = Document.new text
      categories.values.map do |cat|
        prob_cat = cat.probability self
        prob_doc = cat.probability_of_document(doc, default_prob)
        [prob_cat * prob_doc, cat]
      end
    end
    
    def log_classifications text, default_prob = 0.05
      doc = Document.new text
      categories.values.map do |cat|
        prob_cat = cat.log_probability self
        prob_doc = cat.log_probability_of_document(doc, default_prob)
        [prob_cat + prob_doc, cat]
      end
    end

    def classify(text)
      log_classifications(text).inject([-Float::MAX, nil]) do |max, cs_pair|
        max.first > cs_pair.first ? max : cs_pair
      end.last.name
    end
    
    def store_terms doc
      doc.each do |term, count|
        @term_frequencies[term] += count
      end
    end
    
    def remove_terms doc
      doc.each do |term, count|
        next unless @term_frequencies.key?(term)
        freq = @term_frequencies[term]
        @term_frequencies[term] -= (freq >= count ? count : freq)
      end
    end
    
    def count_term term
      @term_frequencies.key?(term) ? @term_frequencies[term] : 0
    end
    
    def count_terms
      @term_frequencies.inject(0) { |sum, (w,c)| sum + c }
    end
    
    def count_unique_terms
      @term_frequencies.size
    end
  end
end
