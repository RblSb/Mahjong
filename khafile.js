let project = new Project("The Legend of Mahjong");
project.addAssets('res/**', {
	nameBaseDir: 'res',
	destination: '{dir}/{name}',
	name: '{dir}/{name}'
});
project.addSources('src');
//project.addDefine('debug');
project.addParameter('-dce full');

resolve(project);
