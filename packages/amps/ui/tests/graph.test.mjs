import { test } from "node:test";
import assert from "node:assert/strict";
import {
	validateConnection,
	waveformPoints,
	trace,
	loadLayout,
	reconcilePositions
} from "../src/graph.mjs";
const ids = [
	"game",
	"comms",
	"music",
	"chatgpt",
	"clean_mic",
	"chatgpt_in",
	"comms_send",
	"monitor"
];
const topology = {
	nodes: ids.map(id => ({
		id,
		inputs: [{ id: "in", editable: !["clean_mic", "chatgpt"].includes(id) }],
		outputs: [{ id: "out", editable: !["chatgpt_in", "comms_send", "monitor"].includes(id) }]
	})),
	edges: []
};
const patches = [
	["game", "monitor"],
	["comms", "monitor"],
	["music", "monitor"],
	["chatgpt", "monitor"],
	["clean_mic", "chatgpt_in"],
	["clean_mic", "comms_send"],
	["comms", "chatgpt_in"],
	["chatgpt", "comms_send"]
].map(([source, destination]) => ({ source, destination }));
const connection = (source, target) => ({
	source,
	target,
	sourceHandle: "out",
	targetHandle: "in"
});
test("direct and indirect participant self-return blocked with clear display names", () => {
	for (const [source, target, label] of [
		["comms", "comms_send", "Comms Audio → Comms Mic"],
		["chatgpt", "chatgpt_in", "AI Audio → AI Mic"]
	]) {
		assert.equal(
			validateConnection(topology, patches, connection(source, target)),
			`Blocked self-return: ${label}.`
		);
		assert.match(
			validateConnection(
				topology,
				[...patches, { source: "music", destination: target }],
				connection(source, "music")
			),
			/self-return/
		);
	}
});
test("protected ports and duplicate links rejected", () => {
	assert.match(validateConnection(topology, patches, connection("music", "clean_mic")), /fixed/);
	assert.match(validateConnection(topology, patches, connection("chatgpt_in", "music")), /fixed/);
	assert.match(
		validateConnection(topology, patches, connection("game", "monitor")),
		/already exists/
	);
});
test("private phone cannot be plugged into recording or voice buses", () => {
	const withPhone = {
		...topology,
		nodes: [
			...topology.nodes,
			{ id: "phone", inputs: [], outputs: [{ id: "out", editable: false }] }
		]
	};
	for (const target of ids) {
		assert.match(validateConnection(withPhone, patches, connection("phone", target)), /fixed/);
	}
});
test("valid fanout and reconnect validate the final graph", () => {
	assert.equal(validateConnection(topology, patches, connection("music", "comms_send")), null);
	assert.equal(
		validateConnection(topology, patches, connection("game", "monitor"), "game:monitor"),
		null
	);
});
test("waveform has no fake activity and consistent distance mapping", () => {
	const geometry = Array.from({ length: 21 }, (_, i) => ({
		x: i * 5,
		y: 0,
		nx: 0,
		ny: 1,
		distance: i * 5
	}));
	assert.equal(waveformPoints(geometry, [0, 0], 0), "");
	const samples = [0.1, 0.4, -0.1, -0.5];
	const longer = [
		...geometry,
		...geometry.slice(1).map(p => ({ ...p, x: p.x + 100, distance: p.distance + 100 }))
	];
	assert.equal(
		waveformPoints(geometry, samples, 0.5).split(" ")[10],
		waveformPoints(longer, samples, 0.5).split(" ")[10]
	);
});
test("path tracing includes predecessors and successors only", () => {
	const edges = [
		{ id: "a", source: "mic", target: "filter" },
		{ id: "b", source: "filter", target: "send" },
		{ id: "c", source: "game", target: "monitor" }
	];
	assert.deepEqual([...trace({ edges }, "filter")], ["a", "b"]);
});
test("unknown and malformed layout versions are ignored", () => {
	assert.equal(loadLayout({ getItem: () => "{" }), null);
	assert.equal(loadLayout({ getItem: () => JSON.stringify({ version: 2, positions: {} }) }), null);
});
test("new phone node cannot obscure a saved microphone position", () => {
	const children = [
		{ id: "phone", x: 0, y: 0, width: 260, height: 190 },
		{ id: "physical_mic", x: 0, y: 300, width: 260, height: 190 },
		{ id: "noise_filter", x: 440, y: 0, width: 260, height: 190 }
	];
	const saved = { physical_mic: { x: 0, y: 0 }, noise_filter: { x: 440, y: 0 } };
	const result = reconcilePositions(children, saved);
	assert.deepEqual(result.physical_mic, saved.physical_mic);
	assert.deepEqual(result.noise_filter, saved.noise_filter);
	assert.deepEqual(result.phone, { x: 0, y: 244 });
	assert.deepEqual(reconcilePositions(children, result), result);
});
test("repair an already-saved overlap without resetting the rest of the graph", () => {
	const children = ["physical_mic", "phone", "music"].map(id => ({
		id,
		x: 0,
		y: 0,
		width: 260,
		height: 190
	}));
	const saved = {
		physical_mic: { x: 12, y: 12 },
		phone: { x: 12, y: 12 },
		music: { x: 800, y: 50 }
	};
	const result = reconcilePositions(children, saved);
	assert.deepEqual(result.physical_mic, saved.physical_mic);
	assert.deepEqual(result.music, saved.music);
	assert.equal(result.phone.y, 256);
});
