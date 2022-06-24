#
#
#
using Colors

# Initialize window dimensions
WIDTH = 1200
HEIGHT = 1150
BACKGROUND = colorant"antiquewhite"

header = 150


# Define Snake
snake_pos_x = WIDTH / 2
snake_pos_y = (HEIGHT - header) / 2 + header

snake_size = 25

snake_color = colorant"green"

snake_head = Rect(
    snake_pos_x, snake_pos_y, snake_size, snake_size
)


# Snake Growth
snake_body = []

function grow()
    push!(snake_body,
        Rect(snake_head.x, snake_head.y, snake_size, snake_size)
    )
end

grow()


# Apple characteristics and spawn rules
function spawn()
    xrange = collect(0:snake_size:(WIDTH - snake_size))
    yrange = collect(header:snake_size:(HEIGHT - snake_size))

    x = rand(xrange)
    y = rand(yrange)

    occuppied = []
    for i in 1:length(snake_body)
        push!(occuppied, (snake_body[i].x, snake_body[i].y))
    end

    if (x, y) in occuppied
        spawn()
    else
        return x, y
    end
end

apple_pos_x, apple_pos_y = spawn()
apple_size = snake_size
apple_color = colorant"red"

apple = Rect(
    apple_pos_x, apple_pos_y, apple_size, apple_size
)


# Header Box
headerbox = Rect(0,0, WIDTH, header)

# Game Variables
score = 0
gameover = false

# Define Actors
function draw(g::Game)
    # Snake
    draw(snake_head, snake_color, fill = true)
    for i in 1:length(snake_body)
        draw(snake_body[i], snake_color, fill = true)
    end

    # Apple
    draw(apple, apple_color, fill = true)

    # Header
    draw(headerbox, colorant"royalblue", fill = true)

    # Score / re-play
    if gameover == false
        display = "Score: $score"
    else
        display = "               GAME OVER            Final Score: $score"
        replay = TextActor("Click to play Again", "Koulen-Regular";
            font_size = 36, color = Int[0, 0, 0, 255]
        )
        replay.pos = (145, 400)
        draw(replay)
    end
    txt = TextActor(display, "koulen-regular";
        font_size = 36, color = Int[255, 255, 0, 255]
    )
    txt.pos = (30, 30)
    draw(txt)
end


# Move Snake
speed = snake_size

vx = speed
vy = 0

function  move()
    snake_head.x += vx
    snake_head.y += vy
end

# Adding delay between each frame to essentially slow down 
# game FPS as it is locked at 60 with GameZero
delay = 0.2
delay_limit = 0.05


# Out of bounds
function border()
    global gameover
    if snake_head.x == WIDTH ||
        snake_head.x < 0 ||
        snake_head.y == HEIGHT ||
        snake_head.y < header
            gameover = true
    end
end

# Collisions
function collided_body()
    global gameover
    for i in 1:length(snake_body)
        if collide(snake_head, snake_body[i])
            gameover = true
        end
    end
end

function collided_apple()
    global delay
    if collide(snake_head, apple)
        # Spawn new apple
        apple.x, apple.y = spawn()
        # Grow Snake
        grow()
        # Speed up
        if delay > delay_limit
            delay -= 0.01
        end
    end
end


# Update function
function update(g::Game)
    if gameover == false
        global snake_body, score
        move()
        border()
        collided_body()
        collided_apple()
        grow()
        popat!(snake_body, 1)
        score = length(snake_body) -1
        sleep(delay)
    end
end


# User interactions
function direction(x, y)
    global vx, vy
    vx = x 
    vy = y    
end

right() = direction(speed, 0)
left() = direction(-speed, 0)
up() = direction(0, -speed)
down() = direction(0, speed)

function on_key_down(g::Game, k)
    if g.keyboard.RIGHT
        if vx !== -speed
            right()
        end
    elseif g.keyboard.LEFT
        if vx !== speed
            left()
        end
    elseif g.keyboard.UP
        if vy !== speed
            up()
        end
    elseif g.keyboard.DOWN
        if vy !== -speed
            down()
        end
    end
end


# Reset game
function reset()
    global snake_head, snake_body
    snake_head = Rect(
        snake_pos_x, snake_pos_y, snake_size, snake_size
    )
    snake_body = []
    grow()
    
    global apple_pos_x, apple_pos_y, apple
    apple_pos_x, apple_pos_y = spawn()
    apple = Rect(
        apple_pos_x, apple_pos_y, apple_size, apple_size
    )

    global score, vx, vy, delay
    score = 0
    vx = speed
    vy = 0
    delay = 0.2

    global gameover
    gameover = false
end

function on_mouse_down(g::Game)
    if gameover == true
        reset()
    end
end