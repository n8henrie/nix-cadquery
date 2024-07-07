{
  fetchFromGitHub,
  python3Packages,
  casadipy,
  nloptpy,
  ocp,
  buildIpopt ? false,
}:
let
  pname = "cadquery";
  version = "2.4.0";
  inherit (python3Packages) buildPythonPackage pytestCheckHook;
in
buildPythonPackage {
  inherit pname version;

  # fetchPypi doesn't include tests, use GitHub instead
  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = "cadquery";
    rev = "2.4.0";
    hash = "sha256-f/qnq5g4FOiit9WQ7zs0axCJBITcAtqF18txMV97Gb8=";
  };
  dependencies =
    (with python3Packages; [
      ezdxf
      multimethod
      nptyping
      numpy
      pyparsing
      typing-extensions
      typish
    ])
    ++ [
      (casadipy.override { inherit buildIpopt; })
      nloptpy
      ocp
    ];
  nativeCheckInputs = with python3Packages; [
    docutils
    ipython
    path
    pip
    pytestCheckHook
  ];
  pythonImportsCheck = [ "cadquery" ];
  pytestFlagsArray =
    [ "tests/" ]
    ++ (map (test: "--deselect=${test}") [
      "tests/test_assembly.py::test_constrain"
      "tests/test_assembly.py::test_PointInPlane_constraint"
      "tests/test_assembly.py::test_PointInPlane_3_parts"
      "tests/test_assembly.py::test_PointInPlane_param"
      "tests/test_assembly.py::test_toCompound"
      "tests/test_assembly.py::test_infinite_face_constraint_Plane"
      "tests/test_assembly.py::test_unary_constraints"
      "tests/test_assembly.py::test_fixed_rotation"
      "tests/test_assembly.py::test_point_on_line"
      "tests/test_assembly.py::test_axis_constraint"
      "tests/test_assembly.py::test_point_constraint"
      "tests/test_cadquery.py::TestCadQuery::testText"
      "tests/test_cadquery.py::TestCadQuery::testTextAlignment"
      "tests/test_cadquery.py::TestCadQuery::test_project"
      "tests/test_examples.py::test_example"
    ]);
}
