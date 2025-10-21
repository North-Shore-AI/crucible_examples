defmodule CrucibleExamples.Mock.Datasets do
  @moduledoc """
  Mock benchmark datasets for demonstration purposes.

  Provides realistic questions across different domains:
  - Medical diagnosis (high-stakes decisions)
  - Math problems (GSM8K-style)
  - General knowledge (MMLU-style)
  - Code generation (HumanEval-style)
  """

  @doc """
  Get medical diagnosis questions for ensemble reliability demo.
  """
  def medical_questions do
    [
      %{
        id: 1,
        category: :medical,
        difficulty: :medium,
        question:
          "A 45-year-old patient presents with fatigue, weight gain, and cold intolerance. TSH is elevated. What is the most likely diagnosis?",
        options: ["Hypothyroidism", "Hyperthyroidism", "Diabetes", "Anemia"],
        correct_answer: "Hypothyroidism",
        explanation:
          "Elevated TSH with symptoms of fatigue and cold intolerance indicates hypothyroidism."
      },
      %{
        id: 2,
        category: :medical,
        difficulty: :hard,
        question:
          "Patient with acute chest pain, ST-elevation in leads II, III, aVF. Which coronary artery is most likely affected?",
        options: [
          "Left Anterior Descending",
          "Right Coronary Artery",
          "Left Circumflex",
          "Left Main"
        ],
        correct_answer: "Right Coronary Artery",
        explanation: "Inferior wall STEMI (II, III, aVF) typically indicates RCA occlusion."
      },
      %{
        id: 3,
        category: :medical,
        difficulty: :easy,
        question:
          "A child presents with fever, cough, and inspiratory stridor. What is the most appropriate initial treatment?",
        options: [
          "Intubation",
          "Nebulized epinephrine",
          "Antibiotics",
          "Observation only"
        ],
        correct_answer: "Nebulized epinephrine",
        explanation: "Stridor suggests croup; nebulized epinephrine is first-line treatment."
      },
      %{
        id: 4,
        category: :medical,
        difficulty: :medium,
        question:
          "Patient on warfarin has INR of 8.5 with no bleeding. What is the best management?",
        options: [
          "Hold warfarin, give vitamin K PO",
          "Continue warfarin same dose",
          "Give FFP immediately",
          "Hold warfarin only"
        ],
        correct_answer: "Hold warfarin, give vitamin K PO",
        explanation: "Elevated INR without bleeding: hold warfarin and give oral vitamin K."
      },
      %{
        id: 5,
        category: :medical,
        difficulty: :hard,
        question: "Newborn with bilious vomiting and 'double bubble' sign on X-ray. Diagnosis?",
        options: [
          "Pyloric stenosis",
          "Duodenal atresia",
          "Hirschsprung disease",
          "Intussusception"
        ],
        correct_answer: "Duodenal atresia",
        explanation: "Double bubble sign with bilious vomiting is classic for duodenal atresia."
      }
    ]
  end

  @doc """
  Get math word problems for statistical comparison demo.
  """
  def math_problems do
    [
      %{
        id: 1,
        category: :math,
        difficulty: :easy,
        question:
          "Sarah has 3 times as many apples as Tom. If Tom has 12 apples, how many apples does Sarah have?",
        correct_answer: 36,
        steps: ["Tom has 12 apples", "Sarah has 3x Tom's apples", "12 × 3 = 36"]
      },
      %{
        id: 2,
        category: :math,
        difficulty: :medium,
        question:
          "A train travels 180 miles in 3 hours. At this rate, how many miles will it travel in 7 hours?",
        correct_answer: 420,
        steps: ["Rate = 180 ÷ 3 = 60 mph", "Distance = 60 × 7 = 420 miles"]
      },
      %{
        id: 3,
        category: :math,
        difficulty: :hard,
        question:
          "A store offers a 20% discount, then an additional 15% off the discounted price. What is the total discount percentage?",
        correct_answer: 32.0,
        steps: [
          "After 20% off: pay 80% of original",
          "After 15% off that: pay 85% of 80% = 0.85 × 0.80 = 0.68",
          "Total discount: 1 - 0.68 = 0.32 = 32%"
        ]
      },
      %{
        id: 4,
        category: :math,
        difficulty: :medium,
        question:
          "If 5 workers can complete a job in 12 days, how many days will it take 8 workers to complete the same job?",
        correct_answer: 7.5,
        steps: [
          "Total work = 5 workers × 12 days = 60 worker-days",
          "Time for 8 workers = 60 ÷ 8 = 7.5 days"
        ]
      },
      %{
        id: 5,
        category: :math,
        difficulty: :easy,
        question: "A rectangle has length 15 cm and width 8 cm. What is its perimeter?",
        correct_answer: 46,
        steps: ["Perimeter = 2(length + width)", "= 2(15 + 8) = 2(23) = 46 cm"]
      }
    ]
  end

  @doc """
  Get general knowledge questions (MMLU-style) for monitoring demo.
  """
  def general_knowledge do
    [
      %{
        id: 1,
        category: :science,
        subject: "Physics",
        question: "What is the speed of light in vacuum?",
        options: [
          "299,792,458 m/s",
          "300,000,000 m/s",
          "299,000,000 m/s",
          "298,792,458 m/s"
        ],
        correct_answer: "299,792,458 m/s"
      },
      %{
        id: 2,
        category: :history,
        subject: "World History",
        question: "In which year did World War II end?",
        options: ["1944", "1945", "1946", "1943"],
        correct_answer: "1945"
      },
      %{
        id: 3,
        category: :science,
        subject: "Chemistry",
        question: "What is the chemical symbol for gold?",
        options: ["Go", "Gd", "Au", "Ag"],
        correct_answer: "Au"
      },
      %{
        id: 4,
        category: :geography,
        subject: "Geography",
        question: "What is the capital of Australia?",
        options: ["Sydney", "Melbourne", "Canberra", "Brisbane"],
        correct_answer: "Canberra"
      },
      %{
        id: 5,
        category: :science,
        subject: "Biology",
        question: "How many chromosomes do humans have?",
        options: ["44", "46", "48", "50"],
        correct_answer: "46"
      }
    ]
  end

  @doc """
  Get code generation prompts for trace demo.
  """
  def code_problems do
    [
      %{
        id: 1,
        category: :code,
        language: "Python",
        question: "Write a function to check if a number is prime.",
        correct_solution: """
        def is_prime(n):
            if n < 2:
                return False
            for i in range(2, int(n**0.5) + 1):
                if n % i == 0:
                    return False
            return True
        """,
        test_cases: [
          %{input: 2, expected: true},
          %{input: 17, expected: true},
          %{input: 4, expected: false}
        ]
      },
      %{
        id: 2,
        category: :code,
        language: "Python",
        question: "Write a function to reverse a string.",
        correct_solution: """
        def reverse_string(s):
            return s[::-1]
        """,
        test_cases: [
          %{input: "hello", expected: "olleh"},
          %{input: "world", expected: "dlrow"}
        ]
      }
    ]
  end

  @doc """
  Sample a random question from a category.
  """
  def sample(category) do
    questions =
      case category do
        :medical -> medical_questions()
        :math -> math_problems()
        :general -> general_knowledge()
        :code -> code_problems()
        _ -> []
      end

    Enum.random(questions)
  end

  @doc """
  Get a batch of questions for experiments.
  """
  def batch(category, count) do
    questions =
      case category do
        :medical -> medical_questions()
        :math -> math_problems()
        :general -> general_knowledge()
        :code -> code_problems()
        _ -> []
      end

    # If count > available, cycle through
    questions
    |> Stream.cycle()
    |> Enum.take(count)
  end
end
