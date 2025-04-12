import std.stdio;

import controls.keyboard;
import controls.mouse;
import game.map;
import game.player;
import graphics.camera;
import graphics.mesh;
import graphics.render;
import graphics.shader;
import graphics.texture;
import graphics.window;
import gui.font;
import gui.gui;
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
		GUI.terminate();
		CameraHandler.terminate();
		MeshHandler.terminate();
		TextureHandler.terminate();
		Window.terminate();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	Window.initialize();

	ShaderHandler.newShader("2d", "shader/2d.vert", "shader/2d.frag");

	TextureHandler.initialize();

	// SetWindowState(ConfigFlags.FLAG_VSYNC_HINT);
	// SetTargetFPS(100);

	GUI.initialize();

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

			ClearBackground(Colors.BLACK);

			CameraHandler.begin();
			{
				Map.draw();

				// Map.drawDebugPoints();

				// Render.circle(Mouse.getWorldPosition(), 0.1, Colors.RED);

				if (!Mouse.isFocusedOnGUI()) {
					import std.math.rounding;

					Vec2d mousePos = Mouse.getWorldPosition();

					mousePos.x = floor(mousePos.x);
					mousePos.y = floor(mousePos.y) + 1;

					Render.rectangleLines(mousePos, Vec2d(1, 1), Colors.WHITE, 0.03);
				}

				Player.draw();
				if (!Mouse.isFocusedOnGUI()) {
					if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
						Map.setTileAtWorldPositionByID(Mouse.getWorldPosition(), 0);
					} else if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)) {
						Map.setTileAtWorldPositionByName(Mouse.getWorldPosition(), "endless_industry.water_0");
					}
				}
			}
			CameraHandler.end();

			// Vec2d center = vec2dMultiply(Window.getSize(), Vec2d(0.5, 0.5));
			// DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);

			string worker;

			worker = "fps: " ~ to!string(GetFPS());

			double yPos = 0;
			double xPos = GUI.getGUIScale() * 2.0;
			FontHandler.drawShadowed(worker, xPos, 0, 0.5);
			yPos += FontHandler.getTextSize(worker, 0.5).y;

			Vec2d playerPos = Player.getPosition();
			worker = "x: " ~ to!string(playerPos.x);
			FontHandler.drawShadowed(worker, xPos, yPos, 0.5);
			yPos += FontHandler.getTextSize(worker, 0.5).y;

			worker = "y: " ~ to!string(playerPos.y);
			FontHandler.drawShadowed(worker, xPos, yPos, 0.5);
			yPos += FontHandler.getTextSize(worker, 0.5).y;

			worker = "y: " ~ to!string(playerPos.y);
			FontHandler.drawShadowed(worker, xPos, yPos, 0.5);
			yPos += FontHandler.getTextSize(worker, 0.5).y;

			Vec2i inChunk = Player.inWhichChunk();
			worker = "chunk: " ~ to!string(inChunk.x) ~ " | " ~ to!string(inChunk.y);
			FontHandler.drawShadowed(worker, xPos, yPos, 0.5);

			GUI.drawVisible();

		}
		EndDrawing();
	}

	Map.terminate();
}
