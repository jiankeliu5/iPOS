ipos.data = {
	dev: {
		login123: {
			userName: '123',
			password: '456'
		},
		
		itemBySku: {
			validSku1: '440915',
			validSku2: '689751',
			invalidSku: '000000'
		},
		itemByName: {
			match: 'match',
			nomatch: 'zxzxzx-blah'
		},
		
		customer: {
			existing: '612-746-1580',
			newCust: '612-807-6120'
		}
		
	},
	
	test: {
		login123: {
			userName: '123',
			password: '123456'
		}
	},
	
	prod: {
		
	}
}

// Set this to point to the appropriate environment
ipos.data.values = ipos.data['dev'];