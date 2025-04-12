import std.stdio;

import controls.keyboard;
import controls.mouse;
import game.map;
import game.player;
import graphics.camera;
import graphics.font;
import graphics.mesh;
import graphics.render;
import graphics.shader;
import graphics.texture;
import graphics.window;
import math.vec2d;
import math.vec2i;
import mods.api;
import raylib;
import std.conv;
import std.math.traits;
import std.string;
import utility.collision_functions;
import utility.delta;
import utility.save;

void main() {

	scope (exit) {
		// FontHandler.terminate();
		// ShaderHandler.terminate();
		MeshHandler.terminate();
		TextureHandler.terminate();
		Window.terminate();
		CameraHandler.terminate();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	Window.initialize();

	ShaderHandler.newShader("2d", "shader/2d.vert", "shader/2d.frag");

	TextureHandler.initialize();

	// SetWindowState(ConfigFlags.FLAG_VSYNC_HINT);
	// SetTargetFPS(100);

	CameraHandler.initialize();

	Api.initialize();

	Map.initialize();

	MeshHandler.initialize();

	while (Window.shouldStayOpen()) {

		double delta = Delta.getDelta();

		Player.move();

		CameraHandler.centerToPlayer();

		Map.onTick(delta);

		BeginDrawing();
		{
			//! Note: DrawTexture and DrawTexturePro are batched as long as you use the same texture.

			ClearBackground(Colors.BLACK);

			CameraHandler.begin();
			{
				Map.draw();

				// Map.drawDebugPoints();

				// Render.circle(Mouse.getWorldPosition(), 0.1, Colors.RED);

				{
					import std.math.rounding;

					Vec2d mousePos = Mouse.getWorldPosition();

					mousePos.x = floor(mousePos.x);
					mousePos.y = floor(mousePos.y) + 1;

					Render.rectangleLines(mousePos, Vec2d(1, 1), Colors.WHITE, 0.03);
				}

				Player.draw();

				if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
					Map.setTileAtWorldPositionByID(Mouse.getWorldPosition(), 0);
				} else if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)) {
					Map.setTileAtWorldPositionByName(Mouse.getWorldPosition(), "endless_industry.water_0");
				}

			}
			CameraHandler.end();

			Vec2d center = vec2dMultiply(Window.getSize(), Vec2d(0.5, 0.5));
			DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);

			DrawText(toStringz("fps:" ~ to!string(GetFPS())), 0, 0, 120, Colors.WHITE);
			Vec2d playerPos = Player.getPosition();
			DrawText(toStringz("y: " ~ to!string(playerPos.y)), 0, 120, 120, Colors.WHITE);
			DrawText(toStringz("x: " ~ to!string(playerPos.x)), 0, 240, 120, Colors.WHITE);

			Vec2i inChunk = Player.inWhichChunk();
			DrawText(toStringz("chunk:" ~ to!string(inChunk)), 0, 360, 120, Colors.WHITE);

		}
		EndDrawing();
	}

	Map.terminate();
}
