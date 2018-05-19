package;

import massive.munit.Assert;
import mahjong.Agari;
import mahjong.Types;

class TilesTest {
	
	@Test
	function test_convert_to_one_line_string():Void {
		var tiles:Tiles136 = [0, 1, 34, 35, 36, 37, 70, 71, 72, 73, 106, 107, 108, 109, 133, 134];
		var result = tiles.toTiles34().toString();
		Assert.areEqual('1199m1199p1199s1177z', result);
	}
	
	@Test
	function test_from_string():Void {
		var tiles = Tiles136.fromString({man: '1199', pin: '1199', sou: '1199', honors: '1177'});
		Assert.areEqual('1199m1199p1199s1177z', tiles.toString());
		
		var tiles = Tiles136.fromString({sou: '123456789', honors: '11777'});
		Assert.areEqual('123456789s11777z', tiles.toString());
		
		var tiles = Tiles34.fromString({sou: '44467778', pin: '222567'});
		Assert.areEqual('222567p44467778s', tiles.toString());
		
		var tiles = Tiles34.fromString({sou: '777'});
		Assert.areEqual('777s', tiles.toString());
	}
	
	@Test
	function test_convert_to_34_array():Void {
		var tiles:Tiles136 = [0, 34, 35, 36, 37, 70, 71, 72, 73, 106, 107, 108, 109, 134];
		var result = tiles.toTiles34();
		Assert.areEqual(result[0], 1);
		Assert.areEqual(result[8], 2);
		Assert.areEqual(result[9], 2);
		Assert.areEqual(result[17], 2);
		Assert.areEqual(result[18], 2);
		Assert.areEqual(result[26], 2);
		Assert.areEqual(result[27], 2);
		Assert.areEqual(result[33], 1);
		var sum = 0;
		for (i in result) sum += i;
		Assert.areEqual(14, sum);
	}
	
	@Test
	function test_convert_to_136_array():Void {
		var tiles:Tiles136 = [0, 32, 33, 36, 37, 68, 69, 72, 73, 104, 105, 108, 109, 132];
		var result = tiles.toTiles34();
		var result = result.toTiles136();
		Assert.isTrue(compareArrays(result.toArray(), tiles.toArray()));
	}
	
	@Test
	function test_convert_string_to_136_array():Void {
		var tiles = Tiles136.fromString({sou: '19', pin: '19', man: '19', honors: '1234567'});
		var arr = [0, 32, 36, 68, 72, 104, 108, 112, 116, 120, 124, 128, 132];
		Assert.isTrue(compareArrays(arr, tiles.toArray()));
	}
	
	function compareArrays<T>(arr:Array<T>, arr2:Array<T>):Bool {
		var equal = true;
		for (i in 0...arr.length)
		if (arr[i] != arr2[i]) {
			equal = false;
			break;
		}
		return equal;
	}
	
}
