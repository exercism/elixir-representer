{:defmodule, [],
 [
   {:__aliases__, [], [:PLACEHOLDER_1]},
   [
     do: {:__block__, [],
      [
        {:def, [],
         [
           {:PLACEHOLDER_2, [],
            [{:\\, [], [{:PLACEHOLDER_3, [], nil}, "world"]}]},
           [
             do: {:<<>>, [],
              [
                "Hello, ",
                {:"::", [],
                 [
                   {{:., [], [Kernel, :to_string]}, [],
                    [{:PLACEHOLDER_3, [], nil}]},
                   {:binary, [binary_helper: true], nil}
                 ]}
              ]}
           ]
         ]},
        {:@, [],
         [
           {:spec, [],
            [
              {:"::", [],
               [
                 {:add_then_subtract, [],
                  [{:integer, [], []}, {:integer, [], []}, {:integer, [], []}]},
                 {:integer, [], []}
               ]}
            ]}
         ]},
        {:def, [],
         [
           {:PLACEHOLDER_4, [],
            [
              {:PLACEHOLDER_5, [], nil},
              {:PLACEHOLDER_6, [], nil},
              {:PLACEHOLDER_7, [], nil}
            ]},
           [
             do: {:__block__, [],
              [
                {:=, [],
                 [
                   {:PLACEHOLDER_8, [], nil},
                   {:+, [],
                    [{:PLACEHOLDER_5, [], nil}, {:PLACEHOLDER_6, [], nil}]}
                 ]},
                {:-, [], [{:PLACEHOLDER_8, [], nil}, {:PLACEHOLDER_7, [], nil}]}
              ]}
           ]
         ]},
        {:def, [],
         [
           {:PLACEHOLDER_9, [], [{:PLACEHOLDER_10, [], nil}]},
           [
             do: {:case, [],
              [
                {:PLACEHOLDER_10, [], nil},
                [
                  do: [
                    {:->, [],
                     [
                       [
                         {:when, [],
                          [
                            {:PLACEHOLDER_10, [], nil},
                            {:is_bitstring, [], [{:PLACEHOLDER_10, [], nil}]}
                          ]}
                       ],
                       :string
                     ]},
                    {:->, [],
                     [
                       [
                         {:when, [],
                          [
                            {:PLACEHOLDER_10, [], nil},
                            {:is_number, [], [{:PLACEHOLDER_10, [], nil}]}
                          ]}
                       ],
                       :number
                     ]},
                    {:->, [],
                     [
                       [
                         {:when, [],
                          [
                            {:PLACEHOLDER_10, [], nil},
                            {:is_boolean, [], [{:PLACEHOLDER_10, [], nil}]}
                          ]}
                       ],
                       :boolean
                     ]}
                  ]
                ]
              ]}
           ]
         ]},
        {:def, [], [{:PLACEHOLDER_11, [], []}, [do: true]]}
      ]}
   ]
 ]}