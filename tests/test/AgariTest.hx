package;

import massive.munit.Assert;
import mahjong.Agari;
import mahjong.Types;

class AgariTest {
	
	@Test
	function test_is_agari():Void {
		var agari = new Agari();
		
		var tiles = Tiles34.fromString({sou: '123456789', pin: '123', man: '33'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '123456789', pin: '11123'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '123456789', honors: '11777'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '12345556778899'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '11123456788999'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '233334', pin: '789', man: '345', honors: '55'});
		Assert.isTrue(agari.is_agari(tiles));
	}
	
	@Test
	function test_is_not_agari():Void {
		var agari = new Agari();
		
		var tiles = Tiles34.fromString({sou: '123456789', pin: '12345'});
		Assert.isFalse(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '111222444', pin: '11145'});
		Assert.isFalse(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '11122233356888'});
		Assert.isFalse(agari.is_agari(tiles));
	}
	
	@Test
	function test_is_chitoitsu_agari():Void {
		var agari = new Agari();
		
		var tiles = Tiles34.fromString({sou: '1133557799', pin: '1199'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '2244', pin: '1199', man: '11', honors: '2277'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({man: '11223344556677'});
		Assert.isTrue(agari.is_agari(tiles));
	}
	
	@Test
	function test_is_kokushi_musou_agari():Void {
		var agari = new Agari();
		
		var tiles = Tiles34.fromString({sou: '19', pin: '19', man: '199', honors: '1234567'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '19', pin: '19', man: '19', honors: '11234567'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '19', pin: '19', man: '19', honors: '12345677'});
		Assert.isTrue(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '129', pin: '19', man: '19', honors: '1234567'});
		Assert.isFalse(agari.is_agari(tiles));
		
		var tiles = Tiles34.fromString({sou: '19', pin: '19', man: '19', honors: '11134567'});
		Assert.isFalse(agari.is_agari(tiles));
	}
	
	@Test
	function test_is_agari_and_open_hand():Void {
		var agari = new Agari();
		var tiles = Tiles34.fromString({sou: '23455567', pin: '222', man: '345'});
		var melds = [
			Tiles34.fromString({man: '345'}),
			Tiles34.fromString({sou: '555'}),
		];
		Assert.isFalse(agari.is_agari(tiles, melds));
	}
	
}
