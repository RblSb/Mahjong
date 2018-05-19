package;

import massive.munit.Assert;
import mahjong.Shanten;
import mahjong.Types;

class ShantenTest {
	
	@Test
	function test_shanten_number():Void {
		var shanten = new Shanten();
		
		var tiles = Tiles34.fromString({sou: '111234567', pin: '11', man: '567'});
		Assert.areEqual(shanten.calculate_shanten(tiles), Shanten.AGARI_STATE);
		
		tiles = Tiles34.fromString({sou: '111345677', pin: '11', man: '567'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 0);
		
		tiles = Tiles34.fromString({sou: '111345677', pin: '15', man: '567'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 1);
		
		tiles = Tiles34.fromString({sou: '11134567', pin: '15', man: '1578'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 2);
		
		tiles = Tiles34.fromString({sou: '113456', pin: '1358', man: '1358'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 3);
		
		tiles = Tiles34.fromString({sou: '1589', pin: '13588', man: '1358', honors: '1'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 4);
		
		tiles = Tiles34.fromString({sou: '159', pin: '13588', man: '1358', honors: '12'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 5);
		
		tiles = Tiles34.fromString({sou: '1589', pin: '258', man: '1358', honors: '123'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 6);
		
		tiles = Tiles34.fromString({sou: '11123456788999'});
		Assert.areEqual(shanten.calculate_shanten(tiles), Shanten.AGARI_STATE);
		
		tiles = Tiles34.fromString({sou: '11122245679999'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 0);
	}
	
	@Test
	function test_shanten_number_and_chitoitsu():Void {
		var shanten = new Shanten();
		
		var tiles = Tiles34.fromString({sou: '114477', pin: '114477', man: '77'});
		Assert.areEqual(shanten.calculate_shanten(tiles), Shanten.AGARI_STATE);
		
		tiles = Tiles34.fromString({sou: '114477', pin: '114477', man: '76'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 0);
		
		tiles = Tiles34.fromString({sou: '114477', pin: '114479', man: '76'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 1);
		
		tiles = Tiles34.fromString({sou: '114477', pin: '14479', man: '76', honors: '1'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 2);
	}
	
	@Test
	function test_shanten_number_and_kokushi_musou():Void {
		var shanten = new Shanten();
		
		var tiles = Tiles34.fromString({sou: '19', pin: '19', man: '19', honors: '12345677'});
		Assert.areEqual(shanten.calculate_shanten(tiles), Shanten.AGARI_STATE);
		
		tiles = Tiles34.fromString({sou: '129', pin: '19', man: '19', honors: '1234567'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 0);
		
		tiles = Tiles34.fromString({sou: '129', pin: '129', man: '19', honors: '123456'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 1);
		
		tiles = Tiles34.fromString({sou: '129', pin: '129', man: '129', honors: '12345'});
		Assert.areEqual(shanten.calculate_shanten(tiles), 2);
	}
	
	@Test
	function test_shanten_number_and_open_sets():Void {
		var shanten = new Shanten();
		
		var tiles = Tiles34.fromString({sou: '44467778', pin: '222567'});
		Assert.areEqual(shanten.calculate_shanten(tiles), Shanten.AGARI_STATE);
		
		var melds = [setToString({sou: '777'})];
		Assert.areEqual(shanten.calculate_shanten(tiles, melds), 0);
		
		tiles = Tiles34.fromString({sou: '23455567', pin: '222', man: '345'});
		var melds = [
			setToString({man: '345'}),
			setToString({sou: '555'}),
		];
		Assert.areEqual(shanten.calculate_shanten(tiles, melds), 0);
	}
	
	function setToString(data:StringTiles):Tiles34 {
		var open_set = Tiles136.fromString(data).toArray();
		for (i in 0...3) open_set[i] = Std.int(open_set[i] / 4);
		return open_set;
	}
	
}
