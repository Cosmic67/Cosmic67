import math
import random
import pygame
import pymunk
from pygame import Color

WIDTH, HEIGHT = 800, 600
FPS = 60

# Colors
BG_COLOR = Color("#1e1e1e")
LIGHT_COLOR = (255, 255, 200, 50)


def create_ragdoll(space, position):
    """Create a simple ragdoll composed of circles and segments."""
    bodies = []

    # Torso
    mass = 5
    radius = 20
    moment = pymunk.moment_for_circle(mass, 0, radius)
    body = pymunk.Body(mass, moment)
    body.position = position
    shape = pymunk.Circle(body, radius)
    shape.friction = 0.8
    space.add(body, shape)
    bodies.append((body, shape, Color("dodgerblue")))

    # Head
    head_mass = 2
    head_radius = 15
    head_moment = pymunk.moment_for_circle(head_mass, 0, head_radius)
    head_body = pymunk.Body(head_mass, head_moment)
    head_body.position = position + (0, -35)
    head_shape = pymunk.Circle(head_body, head_radius)
    head_shape.friction = 0.8
    space.add(head_body, head_shape)
    bodies.append((head_body, head_shape, Color("lightgray")))

    # Joint between head and torso
    joint = pymunk.PivotJoint(body, head_body, position + (0, -20))
    space.add(joint)

    return bodies


def spawn_particles(particles, position, intensity=10):
    for _ in range(intensity):
        vel = [random.uniform(-100, 100), random.uniform(-100, 0)]
        life = random.uniform(0.5, 1.5)
        particles.append([position[0], position[1], vel, life])


def update_particles(particles, dt):
    for p in particles:
        p[0] += p[2][0] * dt
        p[1] += p[2][1] * dt
        p[3] -= dt
    particles[:] = [p for p in particles if p[3] > 0]


def draw_particles(screen, particles):
    for x, y, _, life in particles:
        alpha = int(255 * (life / 1.5))
        color = (200, 50, 50, alpha)
        surface = pygame.Surface((4, 4), pygame.SRCALPHA)
        pygame.draw.circle(surface, color, (2, 2), 2)
        screen.blit(surface, (x-2, y-2))


def draw_lighting(screen):
    light = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
    pygame.draw.circle(light, LIGHT_COLOR, (WIDTH // 2, HEIGHT // 2), 300)
    screen.blit(light, (0, 0), special_flags=pygame.BLEND_RGB_ADD)


def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    clock = pygame.time.Clock()

    space = pymunk.Space()
    space.gravity = (0, 981)

    # Ground
    ground = pymunk.Segment(space.static_body, (0, HEIGHT-50), (WIDTH, HEIGHT-50), 5)
    ground.friction = 1.0
    space.add(ground)

    ragdoll = create_ragdoll(space, (WIDTH/2, HEIGHT/2 - 100))
    particles = []

    running = True
    while running:
        dt = clock.tick(FPS) / 1000
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                pos = pygame.mouse.get_pos()
                spawn_particles(particles, pos, intensity=30)

        space.step(dt)
        update_particles(particles, dt)

        screen.fill(BG_COLOR)

        # Draw ragdoll
        for body, shape, color in ragdoll:
            x, y = body.position
            pygame.draw.circle(screen, color, (int(x), int(y)), int(shape.radius))

        # Draw ground
        pygame.draw.line(screen, Color("#555"), (0, HEIGHT-50), (WIDTH, HEIGHT-50), 5)

        draw_particles(screen, particles)
        draw_lighting(screen)

        pygame.display.flip()

    pygame.quit()


if __name__ == "__main__":
    main()
