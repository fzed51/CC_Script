dofile('advTurtle')

item.add('coal',1,64)

local function farm()
  if turtle.detectDown() then
    tryDown()
    tryDigDown()
    tryUp()  
  end
end

while true do
  tryForward()
  for _=1,4 do
    while not turtle.detect() do
      tryForward()
      farm()
    end
    turnRight()
  end
  turnBack()
  tryForward()
  turnBack()
  os.sleep(60)
end
