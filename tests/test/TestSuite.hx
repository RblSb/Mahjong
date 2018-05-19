import massive.munit.TestSuite;

import AgariTest;
import ShantenTest;
import TilesTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
	public function new()
	{
		super();

		add(AgariTest);
		add(ShantenTest);
		add(TilesTest);
	}
}
