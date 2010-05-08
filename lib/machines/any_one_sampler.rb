module AnswerFactory
  class AnyOneSampler < Sampler
    def generate(crowd)
      result = Batch[crowd.sample]
    end
  end
end