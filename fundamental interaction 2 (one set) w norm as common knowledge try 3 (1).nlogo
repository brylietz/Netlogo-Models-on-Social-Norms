globals [
  norm
  sanction/action
  sanction/not-action
  ignore/action
  ignore/not-action
  action
  not-action
  action-score
  not-action-score
  sanction-score
  ignore-score
  file
  commonKnowledge
  counter1
  counter2
  counter3
  numOfrounds
  num-of-turtles-met ;;again, this is new
]

turtles-own [
  strategy
  sanction?
  ignore?
  action?
  history
  partner-history
  score
  knowledge
  distance-travelled ;;this is new addition to the model. I want to see what the rate of change is for something to
  ;;become common knowledge
  rate-of-change-commonknowledge
]

to setup
  clear-all
  setup-turtles
  setup-payoffs
  setup-history-lists
  setup-commonKnowledge
  setup-knowledge
  setup-scores
  setup-score
  reset-ticks
end

to setup2
  setup-turtles
  setup-payoffs
  setup-history-lists
  setup-commonKnowledge
  setup-knowledge
  setup-scores
  setup-score
  reset-ticks
end

to setup-turtles ;will eventually make this like 'make-turtles' in PD game
  create-turtles num-ignore
  [
    setxy random-xcor random-ycor
    set shape "person"
    set strategy "ignore"
    set history ["ignore"]
    set color blue
    set label "ignore"
  ]

  create-turtles num-sanction
  [
    setxy random-xcor random-ycor
    set shape "person"
    set strategy "sanction"
    set history ["sanction"]
    set color violet
    set label "sanction"
  ]

  create-turtles num-action
  [
    setxy random-xcor random-ycor
    set shape "person"
    set strategy "action"
    set history ["action"]
    set color orange
    set label "action"
  ]

  create-turtles num-not-action
  [
    setxy random-xcor random-ycor
    set shape "person"
    set strategy "not-action"
    set history ["not-action"]
    set color green
    set label "agent4"
  ]
end

to setup-payoffs
  set sanction/action list -1 -2
  set sanction/not-action list 0 0
  set ignore/action list 1 -1
  set ignore/not-action list 0 0
end

to setup-score
  let num-turtles count turtles

  let default-score [] ;;initialize the DEFAULT-HISTORY variable to be a list

  repeat num-turtles [ set default-score (fput 0 default-score) ]

  ask turtles [set score default-score]
end

to setup-history-lists
  let num-turtles count turtles

  let default-history [] ;;initialize the DEFAULT-HISTORY variable to be a list

  repeat num-turtles [ set default-history (fput false default-history) ]

  ask turtles [ set history default-history ]

  ask turtles [set partner-history default-history]

end

to create-file
 set file user-new-file
  ;; We check to make sure we actually got a string just in case
  ;; the user hits the cancel button.
  if is-string? file
  [
    ;; If the file already exists, we begin by deleting it, otherwise
    ;; new data would be appended to the old contents.
    if file-exists? file
      [ file-delete file ]
    file-open file
    ;; record the initial turtle data
    write-to-file
  ]
end

to write-to-file
  set counter3 ticks
   ;export-plot "Payoffs" file
   if (counter3 > 1000)
    [
    file-print (word "Round: " numOfrounds "-----")
    ;file-write sum(action-score)
    file-print (word "------ Action Score: " sum(action-score) "------")
    ;file-write sum(not-action-score)
    file-print (word "------ Not-Action Score: " sum(not-action-score) "------")
    ;file-write sum(sanction-score)
    file-print (word "------ Sanction Score: " sum(sanction-score) "------")
    ;file-write sum(ignore-score)
    file-print (word "------ Ignore Score: " sum(ignore-score) "------")
    file-print ""  ;; blank line
    clear-turtles
    clear-plot
    setup2
    set numOfrounds numOfrounds + 1
    ]
  ;file-print (action-score)
  ;file-print ""  ;; blank line
end



to setup-knowledge
  ask turtles
  [
    set knowledge ["sanction" "ignore" "action" "not-action"]
  ]
end

to setup-commonKnowledge
  set commonKnowledge false
end

to setup-scores
  set sanction-score list 0 0
  set ignore-score list 0 0
  set action-score list 0 0
  set not-action-score list 0 0
end

to go
 move-turtles
 gain-knowledge
 outcome-action-ignore-with-knowledge
 outcome-action-sanction-with-knowledge
 outcome-not-action-sanction-with-knowledge
 compare-strategies
 ;introduce-agents
 calculate-rate-of-change-commonKnowledge ;; this is new
 ask turtles [select-strategy]
 norm?
 commonKnowledge?
 tick
 if (file != 0)
  [write-to-file]
end

to select-strategy
  if strategy = "action" [choose-action]
  if strategy = "not-action" [choose-not-action]
  if strategy = "ignore" [choose-ignore]
  if strategy = "sanction" [choose-sanction]
end

to choose-ignore
 set ignore? true
end

to choose-sanction
  set sanction? true
end

to choose-action
  set action? true
end

to choose-not-action
  set action? false
end

to gain-knowledge
  ask turtles
  [
    let q other turtles-here with [action? = true]
    let r other turtles-here with [action? = false]
    let z other turtles-here with [ignore? = true]
    let a other turtles-here with [sanction? = true]
    if (any? q)
      [
        let p one-of q
        set knowledge replace-item 2 knowledge ["action"]
        set partner-history replace-item ([who] of p) partner-history "action"
        set num-of-turtles-met num-of-turtles-met + 1
      ]

    if (any? r)
        [
          let b one-of r
          set knowledge replace-item 3 knowledge ["not-action"]
          set partner-history replace-item ([who] of b) partner-history "not-action"
          set num-of-turtles-met num-of-turtles-met + 1
        ]

    if (any? z)
          [
            let c one-of z
            set knowledge replace-item 1 knowledge ["ignore"]
            set partner-history replace-item ([who] of c) partner-history "ignore"
            set num-of-turtles-met num-of-turtles-met + 1
          ]

    if (any? a)
          [
            let d one-of a
            set knowledge replace-item 0 knowledge ["sanction"]
            set partner-history replace-item ([who] of d) partner-history "sanction"
            set num-of-turtles-met num-of-turtles-met + 1
          ]
   ]
end

to outcome-action-ignore-with-knowledge
ask turtles[
  let action-turtles1 turtles with [member? ["ignore"] knowledge = true and action? = true]
  let ignore-turtles1 other turtles-here with [member? ["action"] knowledge = true and ignore? = true]
  let q one-of ignore-turtles1
  let action-turtles2 other turtles-here with [member? ["ignore"] knowledge = true and action? = true]
  let ignore-turtles2 turtles with [member? ["action"] knowledge = true and ignore? = true]
  let r one-of action-turtles2

  ask action-turtles1
  [
    if (any? ignore-turtles1)
    [
      set history replace-item ([who] of q) history "action"
      set partner-history replace-item ([who] of q) partner-history "ignore"
      ifelse (not all? turtles [action? = true or action? = 0])
            [
              if (norm = 1)
                [
                   set action-score fput item 0 ignore/action action-score
                   set score replace-item ([who] of q) score item 0 ignore/action
                ]
            ]
            [
              if (norm = 1)
               [
                 set action-score fput -2 action-score
                 set score replace-item ([who] of q) score -2
               ]
            ]
    ]
  ]

  ask ignore-turtles2
    [
      if (any? action-turtles2)
      [
        set history replace-item ([who] of r) history "ignore"
        set partner-history replace-item ([who] of r) partner-history "action"
        if (norm = 1)
        [
          set ignore-score fput item 1 ignore/action ignore-score
          set score replace-item ([who] of r) score item 1 ignore/action
        ]
      ]
    ]
  ]
end

to outcome-action-sanction-with-knowledge
  ask turtles[
    let action-turtles1 turtles with [member? ["sanction"] knowledge = true and action? = true]
    let sanction-turtles1 other turtles-here with [member? ["action"] knowledge = true and sanction? = true]
    let q one-of sanction-turtles1
    let action-turtles2 other turtles-here with [member? ["sanction"] knowledge = true and action? = true]
    let sanction-turtles2 turtles with [member? ["action"] knowledge = true and sanction? = true]
    let r one-of action-turtles2

    ask action-turtles1
    [
      if (any? sanction-turtles1)
         [
           set history replace-item ([who] of q) history "action"
           set partner-history replace-item ([who] of q) partner-history "sanction"
          ifelse (not all? turtles [action? = false or action? = 0]);;what if norm != 1? you get action -2 which i'm not sure if thats the right result.
          [
            if (norm = 1)
            [
              set action-score fput item 0 sanction/action action-score
              set score replace-item ([who] of q) score item 0 sanction/action
            ]
           ]
          [
            if (norm = 1)
              [
                set action-score fput -2 action-score
                set score replace-item ([who] of q) score -2
              ]
          ]
      ]
    ]


     ask sanction-turtles2
       [
         if (any? action-turtles2)
            [
              set history replace-item ([who] of r) history "sanction"
              set partner-history replace-item ([who] of r) partner-history "action"
          if (norm = 1)
            [
              set sanction-score fput item 1 sanction/action sanction-score
              set score replace-item ([who] of r) score item 1 sanction/action
            ]
        ]
       ]
  ]
end

to outcome-not-action-sanction-with-knowledge
  ask turtles
  [
    let not-action-turtles1 turtles with [member? ["sanction"] knowledge = true and action? = false]
    let sanction-turtles1 other turtles-here with [member? ["not-action"] knowledge = true and sanction? = true]
    let q one-of sanction-turtles1
    let not-action-turtles2 other turtles-here with [member? ["sanction"] knowledge = true and action? = false]
    let sanction-turtles2 turtles with [member? ["action"] knowledge = true and sanction? = true]
    let r one-of not-action-turtles2

    ask not-action-turtles1
      [
        if (any? sanction-turtles1)
           [
             set history replace-item ([who] of q) history "not-action"
             set partner-history replace-item ([who] of q) partner-history "sanction"
             if (norm = 1)
                [
                  set not-action-score fput item 0 sanction/not-action not-action-score
                  set score replace-item ([who] of q) score item 0 sanction/not-action
                ]
        ]
      ]

    ask sanction-turtles2
      [
        if (any? not-action-turtles2)
           [
             set history replace-item ([who] of r) history "sanction"
             set partner-history replace-item ([who] of r) partner-history "not-action"
             if (norm = 1)
                [
                  set sanction-score fput item 1 sanction/not-action sanction-score
                  set score replace-item ([who] of r) score item 1 sanction/not-action
                ]
        ]
      ]

  ]
end

to compare-strategies
if(commonKnowledge = true)
[
  ask turtles with [strategy = "sanction" or strategy = "ignore"]
  [
    let q other turtles-here
    let s one-of q
    if (any? q)
    [
      if (item [who] of s partner-history = "action")
        [
          if (item [who] of s score < 0)
          [
            ifelse (item 1 ignore/action > item 1 sanction/action)
            [
              set strategy "ignore"
              set sanction? false
            ]
            [
              ifelse (random 1 > .5)
              [
                set strategy "ignore"
                set sanction? false
              ]
              [
                set strategy "sanction"
                set ignore? false
              ]
            ]
          ]
      ]
    ]
  ]



ask turtles with [strategy = "action" or strategy = "not-action"]
  [
    let r other turtles-here
    let p one-of r
    if (any? r)
    [
      if (item [who] of p partner-history = "sanction")
        [
          if (item [who] of p score < 0)
          [
            ifelse (item 0 sanction/action > item 0 sanction/not-action and sum(action-score) >= sum(not-action-score))
            [
              set strategy "action"
              set action? true
            ]
            [
              ifelse (random 1 > .5)
              [
                set strategy "action"
                set action? true
              ]
              [
                set strategy "not-action"
                set action? false
              ]
            ]
          ]
        ]
       if (item [who] of p partner-history = "ignore")
        [
          if (item [who] of p score <= 0)
          [
            ifelse (item 0 ignore/action > item 0 ignore/not-action and sum(action-score) >= sum(not-action-score))
            [
              set strategy "action"
              set action? true
            ]
            [
              ifelse (random 1 > .5)
              [
                set strategy "action"
                set action? true
              ]
              [
                set strategy "not-action"
                set action? false
              ]
            ]
          ]
      ]
    ]
  ]
]
end


to introduce-agents
  set counter1 ticks
  if (counter1 = counter2)
  [
    create-turtles 1
    [
      set shape "person"
      let q list turtles turtles
      foreach q ;;picks a random strategy for each turtle
        [
          let g random 4
          if (g = 0)
            [
              set strategy "sanction"
              set history ["sanction"]
              set label "sanction"
              set color violet
            ]
          if (g = 1)
            [
              set strategy "ignore"
              set history ["ignore"]
              set label "ignore"
              set color blue
            ]
          if (g = 2)
            [
              set strategy "action"
              set history ["action"]
              set label "action"
              set color orange
            ]
          if (g = 3)
            [
              set strategy "not-action"
              set history ["not-action"]
              set label "not-action"
              set color green
            ]
        ]

        let num-turtles count turtles

        let default-history [] ;;initialize the DEFAULT-HISTORY variable to be a list

        let default-score []

        repeat num-turtles [ set default-history (fput false default-history) ]

        repeat num-turtles [set default-score (fput 0 default-score) ]

        set history default-history

        set score default-score

        set partner-history default-history;;need to add to history of other turtles

        set knowledge ["sanction" "ignore" "action" "not-action"]

    ]
    set counter2 counter2 + 1000 ;;orig 100,000
     ask turtles
          [
            set partner-history lput false partner-history
            set history lput false history
            set score lput 0 score
          ]
  ]
end

to norm?
   ifelse (commonKnowledge = true)
  [
    set norm 1
  ]
  [
    set norm 0
  ]
end

to commonKnowledge?
  ifelse(all? turtles [knowledge = [["sanction"] ["ignore"] ["action"] ["not-action"]]])
    [set commonKnowledge true]
    [set commonKnowledge false]
end



to count-score
  set action-score (calc-score "action" num-action)
  set not-action-score (calc-score "not-action" num-not-action)
  set sanction-score (calc-score "sanction" num-sanction)
  set ignore-score (calc-score "ignore" num-ignore)
end

to-report calc-score [strategy-type num-with-strategy]
  ifelse num-with-strategy > 0 [
    report (sum [ score ] of (turtles with [ strategy = strategy-type ]))
  ] [
    report 0
  ]
end


to move-turtles
    ask turtles [
    lt random 360
    rt random 360
    set heading random 360
    fd 1
    set distance-travelled distance-travelled + 1
  ]
end

to calculate-rate-of-change-commonKnowledge
  let flag  true
  ask turtles
  [
    while[commonknowledge = true and flag = true]
    [
      set rate-of-change-commonknowledge distance-travelled / ticks
      ;;show rate-of-change-commonknowledge
      set flag false
    ]
  ]
end










@#$#@#$#@
GRAPHICS-WINDOW
393
31
830
469
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
5
10
68
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
80
10
143
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
4
139
176
172
num-ignore
num-ignore
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
4
178
176
211
num-sanction
num-sanction
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
5
218
177
251
num-action
num-action
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
3
257
175
290
num-not-action
num-not-action
0
100
0.0
1
1
NIL
HORIZONTAL

PLOT
5
299
346
510
Payoffs
time 
payoffs
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Action Score" 1.0 0 -7858858 true "" "plot sum(action-score)"
"Not Action Score" 1.0 0 -14439633 true "" "plot sum(not-action-score)"
"Sanction Score" 1.0 0 -2674135 true "" "plot sum(sanction-score)"
"Ignore Score" 1.0 0 -13345367 true "" "plot sum(ignore-score)"

TEXTBOX
180
147
395
379
 PAYOFF:\n             Agent 1    \nAgent 2      S       I\n-------------------------\n    A    (-1, -1) (1, -1)  \n-------------------------\n  ~A    (0, -2)  (0, 0)\n-------------------------\n(A = Action, S = Sanction, I = Ignore)
11
0.0
1

SLIDER
4
100
176
133
stay-away-from-action
stay-away-from-action
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
3
61
198
94
stay-away-from-sanctions
stay-away-from-sanctions
0
10
0.0
1
1
NIL
HORIZONTAL

BUTTON
248
10
328
43
NIL
file-close
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
152
10
240
43
NIL
create-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
841
115
1361
428
plot 1
ticks
num-of-turtles-met
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"average turtles are running into each other " 1.0 0 -16777216 true "" "plot (num-of-turtles-met) / (count turtles)"
"When commonknowledge is true " 1.0 0 -4079321 true "" "ifelse(commonknowledge = true)[plot 20][plot 0]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
