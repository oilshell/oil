#!/usr/bin/env python2

import unittest
# module under test
from data_lang.pretty import PrettyPrinter, MeasuredDoc, _CycleDetector, _Concat, _Text

from data_lang import j8
from _devbuild.gen.value_asdl import value, value_t
from mycpp import mylib, mops

def IntValue(i):
    # type: (int) -> value_t
    return value.Int(mops.IntWiden(i))

class PrettyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.printer = PrettyPrinter()

    def assertPretty(self, width, value_str, expected):
        # type: (int, str, str) -> None
        parser = j8.Parser(value_str, True)
        val = parser.ParseValue()
        buf = mylib.BufWriter()
        self.printer.SetMaxWidth(width)
        self.printer.PrintValue(val, buf)
        self.assertEqual(buf.getvalue(), expected)

    def testNull(self):
        self.assertPretty(10, "null", "null")

    def testBool(self):
        self.assertPretty(10, "true", "true")
        self.assertPretty(10, "false", "false")

    def testInt(self):
        self.assertPretty(10, "0", "0")
        self.assertPretty(10, "-123", "-123")
        self.assertPretty(10,
            "123456789123456789123456789",
            "123456789123456789123456789")

    def testFloat(self):
        self.assertPretty(10, "  0.0  ", "0.0")
        self.assertPretty(10, "1.0", "1.0")
        self.assertPretty(10, "-0.000", "-0.0")
        self.assertPretty(10, "2.99792458e8", "299792458.0")

    def testString(self):
        self.assertPretty(10, ' "hello"', '"hello"')
        self.assertPretty(10,
            '"\\"For the `n`\'th time,\\" she said."',
            '"\\"For the `n`\'th time,\\" she said."')

    def testList(self):
        self.assertPretty(
            20,
            "[100, 200, 300]",
            "[100, 200, 300]")
        self.assertPretty(
            10,
            "[100, 200, 300]",
            "[\n    100,\n    200,\n    300\n]")

    def testDict(self):
        self.assertPretty(
            30,
            '{"x":100, "y":200, "z":300}',
            '{"x": 100, "y": 200, "z": 300}')
        self.assertPretty(
            29,
            '{"x":100, "y":200, "z":300}',
            '{\n    "x": 100,\n    "y": 200,\n    "z": 300\n}')

class GraphPrinter:
    def __init__(self, graph):
        # type: (List[Tuple[int, int]]) -> None
        self.cycle_detector = _CycleDetector()
        self.graph = graph

    def PrintGraph(self):
        # type: () -> str
        document = self._ShowNodeCyclic(0)
        printer = PrettyPrinter()
        buf = mylib.BufWriter()
        printer._PrintDoc(document, buf)
        return buf.getvalue()

    def _ShowNodeCyclic(self, node):
        # type: int -> MeasuredDoc
        return self.cycle_detector.Visit(node, lambda: self._ShowNode(node))

    def _ShowNode(self, node):
        # type: int -> MeasuredDoc
        return _Concat([
            _Text("("),
            self._ShowNodeCyclic(self.graph[node][0]),
            _Text(", "),
            self._ShowNodeCyclic(self.graph[node][1]),
            _Text(")")])

class CycleDetectorTest(unittest.TestCase):
    """Test displaying a directed graph, where each vertex `i` has two out-edges `graph[i]`."""

    def testCycleDetection(self):
        # Test displaying this spaghetti graph:
        # root -> (a, c)
        #    a -> (a, a)
        #    b -> (b, c)
        #    c -> (a, b)
        graph = [[1, 2], [1, 1], [1, 3], [3, 2]]
        self.assertEqual(
            GraphPrinter(graph).PrintGraph(),
            "(&a (*a, *a), &c (*a, &b (*b, *c)))")

if __name__ == '__main__':
    unittest.main()
