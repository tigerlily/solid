Solid::MethodWhitelist
	.allow(
		BasicObject => [:!, :!=, :==],
		Object => [:present?, :blank?],
		Kernel => [:nil?, :!~],
		Module => [:==],
		Enumerable => [:sort],
		Comparable => [:<, :<=, :==, :>, :>=, :between?],
	).deny(
		Module => [:const_get, :const_set, :const_defined?, :freeze, :ancestors],
		Class => [:new, :allocate, :superclass],
	)
