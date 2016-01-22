import Html exposing (Html, Attribute, text, div, input)
import Html.Attributes exposing (placeholder, value, style)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address)
import StartApp.Simple exposing (start)
import String exposing (toInt)
import Maybe exposing (withDefault)
import List exposing (map, map2)
import List.Extra exposing (scanl1)

lastFridays : Int -> List Int
lastFridays year =
  let isLeap = (year % 400) == 0 || ( (year % 4) == 0 && (year % 100) /= 0 )
      daysInMonth = [31, if isLeap then 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      y = year-1
  in scanl1 (+) daysInMonth
     |> map (\day -> (day + 2 + y + y//4 - y//100 + y//400) % 7) 
     |> map2 (-) daysInMonth 

errString : String
errString = "Only years after 1752 are valid."

months : List String
months= ["January ", "February ", "March ", "April ", "May ", "June ", "July ", "August ", "September ", "October ", "November ", "December "]

lastFridayStrings : String -> List String
lastFridayStrings yearString = 
  case toInt yearString of 
    Ok year -> if (year < 1753) 
                  then [errString] 
                  else lastFridays year
                       |> map toString 
                       |> map2 (++) months 
                       |> map (\s -> s ++ ", " ++ yearString)
    Err _ -> [errString]

main = start { model = "", view = view, update = update }

update newStr oldStr = newStr

view : Address String -> String -> Html
view address yearString =
  div []
    ([ input
        [ placeholder "Enter a year."
        , value yearString
        , on "input" targetValue (Signal.message address)
        , myStyle
        ]
        []
     ] ++ (lastFridayStrings yearString
           |> map (\date -> div [ myStyle ] [ text date ]) ))

myStyle : Attribute
myStyle =
  style
    [ ("width", "100%")
    , ("height", "20px")
    , ("padding", "5px 0 0 5px")
    , ("font-size", "1em")
    , ("text-align", "left")
    ]
