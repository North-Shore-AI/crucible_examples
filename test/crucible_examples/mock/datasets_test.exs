defmodule CrucibleExamples.Mock.DatasetsTest do
  use ExUnit.Case, async: true
  alias CrucibleExamples.Mock.Datasets

  describe "medical_questions/0" do
    test "returns list of medical questions" do
      questions = Datasets.medical_questions()
      assert is_list(questions)
      assert length(questions) > 0
    end

    test "each question has required fields" do
      questions = Datasets.medical_questions()

      for question <- questions do
        assert Map.has_key?(question, :id)
        assert Map.has_key?(question, :category)
        assert Map.has_key?(question, :difficulty)
        assert Map.has_key?(question, :question)
        assert Map.has_key?(question, :correct_answer)
        assert question.category == :medical
      end
    end

    test "questions have valid difficulty levels" do
      questions = Datasets.medical_questions()

      for question <- questions do
        assert question.difficulty in [:easy, :medium, :hard]
      end
    end
  end

  describe "math_problems/0" do
    test "returns list of math problems" do
      problems = Datasets.math_problems()
      assert is_list(problems)
      assert length(problems) > 0
    end

    test "each problem has required fields" do
      problems = Datasets.math_problems()

      for problem <- problems do
        assert Map.has_key?(problem, :id)
        assert Map.has_key?(problem, :category)
        assert Map.has_key?(problem, :question)
        assert Map.has_key?(problem, :correct_answer)
        assert problem.category == :math
      end
    end

    test "correct answers are numeric" do
      problems = Datasets.math_problems()

      for problem <- problems do
        assert is_number(problem.correct_answer)
      end
    end
  end

  describe "general_knowledge/0" do
    test "returns list of general knowledge questions" do
      questions = Datasets.general_knowledge()
      assert is_list(questions)
      assert length(questions) > 0
    end

    test "each question has required fields" do
      questions = Datasets.general_knowledge()

      for question <- questions do
        assert Map.has_key?(question, :id)
        assert Map.has_key?(question, :category)
        assert Map.has_key?(question, :question)
        assert Map.has_key?(question, :options)
        assert Map.has_key?(question, :correct_answer)
      end
    end

    test "questions have multiple choice options" do
      questions = Datasets.general_knowledge()

      for question <- questions do
        assert is_list(question.options)
        assert length(question.options) >= 2
        assert question.correct_answer in question.options
      end
    end
  end

  describe "code_problems/0" do
    test "returns list of code problems" do
      problems = Datasets.code_problems()
      assert is_list(problems)
      assert length(problems) > 0
    end

    test "each problem has required fields" do
      problems = Datasets.code_problems()

      for problem <- problems do
        assert Map.has_key?(problem, :id)
        assert Map.has_key?(problem, :category)
        assert Map.has_key?(problem, :language)
        assert Map.has_key?(problem, :question)
        assert Map.has_key?(problem, :correct_solution)
        assert problem.category == :code
      end
    end

    test "problems have test cases" do
      problems = Datasets.code_problems()

      for problem <- problems do
        assert Map.has_key?(problem, :test_cases)
        assert is_list(problem.test_cases)
        assert length(problem.test_cases) > 0
      end
    end
  end

  describe "sample/1" do
    test "returns random medical question" do
      question = Datasets.sample(:medical)
      assert question.category == :medical
    end

    test "returns random math problem" do
      problem = Datasets.sample(:math)
      assert problem.category == :math
    end

    test "returns random general knowledge question" do
      question = Datasets.sample(:general)
      assert question.category in [:science, :history, :geography]
    end

    test "returns random code problem" do
      problem = Datasets.sample(:code)
      assert problem.category == :code
    end

    test "raises error for invalid category" do
      # Should raise when trying to sample from empty list
      assert_raise Enum.EmptyError, fn ->
        Datasets.sample(:invalid)
      end
    end
  end

  describe "batch/2" do
    test "returns requested number of questions" do
      batch = Datasets.batch(:medical, 10)
      assert length(batch) == 10
    end

    test "cycles through questions if count exceeds available" do
      medical_count = length(Datasets.medical_questions())
      batch = Datasets.batch(:medical, medical_count + 5)
      assert length(batch) == medical_count + 5
    end

    test "all questions are from correct category" do
      batch = Datasets.batch(:math, 8)

      for problem <- batch do
        assert problem.category == :math
      end
    end

    test "raises error for invalid category" do
      # Should raise when trying to cycle over empty list
      assert_raise ArgumentError, fn ->
        Datasets.batch(:invalid, 5)
      end
    end
  end
end
