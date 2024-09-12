
### data selection ###

# programm selection for binding with bouquets and signalbezug

sub selectmodel_PGSEL_pg {
	my ( $self, $c, $cond ) = @_;
	my ( $m, @rowobjs, $row, %data );

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			join => [ qw/ b2_tvp b2_rp b2_bq / ],
			'+select' => [ qw/ b2_tvp.name b2_rp.name b2_bq.name b2_tvp.genre b2_rp.genre b2_bq.betreiber / ],
			'+as' => [ qw/ tvp_name rp_name bq_name tvp_genre rp_genre bq_betreiber / ]
		}
	) or return 0;

	# map result row into JSON data array
	$data{'pgsel'} = ();
	for $row ( @rowobjs ) {
		# don't take dummy record which has uidx 0
		next if ($row->uidx == 0);

		my %e = ();
		$e{'uidx'} = $row->uidx;

		# additional grid-specific mappings
		switch ($row->pg_type) {
			case 1 {
				$e{'pgt'} = 'TV';
				$e{'nam'} = $row->get_column('tvp_name');
				$e{'gnr'} = $row->get_column('tvp_genre');
			}
			case 2 {
				$e{'pgt'} = 'Radio';
				$e{'nam'} = $row->get_column('rp_name');
				$e{'gnr'} = $row->get_column('rp_genre');
			}
			case 3 {
				$e{'pgt'} = 'Bouquet';
				$e{'nam'} = $row->get_column('bq_name');
				$e{'gnr'} = $row->get_column('bq_betreiber');
			}
		}

		push( @{ $data{'pgsel'} }, \%e );
	}

	return \%data;
}


# main programm table maintainance

sub selectmodel_NAME_pg {
	my ( $self, $c, $cond ) = @_;
	my ( $m, $ee, @rowobjs, $row, %data );

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			join => [ qw/ b2_tvp b2_rp b2_bq / ],
			'+select' => [ qw/ b2_tvp.name b2_rp.name b2_bq.name / ],
			'+as' => [ qw/ tvp_name rp_name bq_name / ]
		}
	) or return 0;

	# map result row into JSON data array
	$data{'pg'} = ();
	for $row ( @rowobjs ) {
		# don't take dummy record which has uidx 0
		next if ($row->uidx == 0);

		# call basic mapper
		$ee = get_pg($row);

		# additional grid-specific mappings
		switch ($row->pg_type) {
			case 1 {
				$ee->{'pgt'} = 'TV';
				$ee->{'nam'} = $row->get_column('tvp_name');
			}
			case 2 {
				$ee->{'pgt'} = 'Radio';
				$ee->{'nam'} = $row->get_column('rp_name');
			}
			case 3 {
				$ee->{'pgt'} = 'Bouquet';
				$ee->{'nam'} = $row->get_column('bq_name');
			}
		}

		push( @{ $data{'pg'} }, $ee );
	}

	return \%data;
}


