module Machine::Nudge
  class Destroy < Machine
    def process (answers)
      Factory.destroy_answers(answers)
      return {}
    end
  end
end
